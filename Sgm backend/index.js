const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const cors = require('cors');
const { OpenAI } = require("openai");

const { MongoClient, ObjectId } = require('mongodb');

const MONGO_URI = 'mongodb+srv://vishnuvardhanreddygunreddy:8YAEOXACAJmKmaQ8@studygroupmatcher.s5rsr7h.mongodb.net/';
const JWT_SECRET = 'fW7^3k@1z$L9vQm#Ht4N%jXp!rZ2uSe8';

const app = express();
const PORT = parseInt(process.env.PORT) || 3000;

app.use(cors());
app.use(express.json());
const openai = new OpenAI({
});
let db;

// 🔌 Connect to MongoDB
async function connectDB() {
  const client = new MongoClient(MONGO_URI);
  await client.connect();
  db = client.db('studygroup');
  console.log('MongoDB connected');
}

connectDB().then(() => {
  app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
}).catch(err => console.error(err));

function authMiddleware(req, res, next) {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Unauthorized' });
  try {
    const user = jwt.verify(token, JWT_SECRET);
    req.userId = user.id;
    next();
  } catch (err) {
    res.status(401).json({ error: 'Invalid Token' });
  }
}
app.post('/signup', async (req, res) => {
  const { fullname, mobilenumber, email, password } = req.body;

  console.log('Fullname:', fullname);
  console.log('Mobile Number:', mobilenumber);
  console.log('Email:', email);
  console.log('Password:', password);

  if (!fullname || !mobilenumber || !email || !password) {
    return res.status(400).json({ error: 'All fields are required' });
  }

  const existingUser = await db.collection('users').findOne({ email });
  if (existingUser) return res.status(400).json({ error: 'User already exists' });

  const result = await db.collection('users').insertOne({
    fullname,
    mobilenumber,
    email,
    password, // plain text (not hashed)
    friends: [],
    friendRequests: [],
    bio: null
  });

  const token = jwt.sign({ id: result.insertedId }, JWT_SECRET);
  res.status(200).json({ token });
});


app.post('/login', async (req, res) => {
  const { email, password } = req.body;

  console.log(email)
  const user = await db.collection('users').findOne({ email });

  if (!user || user.password !== password) {
    return res.status(400).json({ error: 'Invalid credentials' });
  }

  const token = jwt.sign({ id: user._id }, JWT_SECRET);
  res.json({ token });
});



app.post('/addbio', authMiddleware, async (req, res) => {
  const {  bio } = req.body;
  await db.collection('users').updateOne({ _id: new ObjectId(req.userId) }, { $set: {  bio } });
  res.json({ message: 'Bio updated' });
});

app.get('/findfriends', authMiddleware, async (req, res) => {
  const user = await db.collection('users').findOne({ _id: new ObjectId(req.userId) }, { projection: { bio: 1, email: 1, fullname: 1 } });

  const users = await db.collection('users').find({}, {
    projection: {
      fullname: 1,
   
      _id:1,
      email:1,

      bio: 1
    }
  }).toArray();

  console.log(users);
  const query = `
  You are given a list of users:
  ${JSON.stringify(users)}
  
  The user with email "${user.email}" is looking for study partners based on their bio.
  
  👉 Your task:
  - From the above list **only**, suggest 3 users who would be a good match as study partners.
  - Do not use any information outside of the provided list.
  - Justify each match using the bio or other available fields.
  
  👉 Format your response strictly as JSON in this structure:
  [
    {
      "_id": "user1_id",
      "fullname": "User One",
      "reasons": ["Reason 1", "Reason 2"]
    },
    ...
  ]
  `;
 try {
  const response = await openai.chat.completions.create({
    model: "gpt-4-0613",
    messages: [{ role: "user", content: query }],
    functions: [
      {
        name: "matched_user_profiles",
        description: "Returns matched profiles for a given user using only provided data",
        parameters: {
          type: "object",
          properties: {
            matches: {
              type: "array",
              items: {
                type: "object",
                properties: {
                  _id: { type: "string" },
                  fullname: { type: "string" },
                  reasons: {
                    type: "array",
                    items: { type: "string" }
                  }
                },
                required: ["_id", "fullname", "reasons"]
              }
            }
          },
          required: ["matches"]
        }
      }
    ],
    function_call: { name: "matched_user_profiles" }
  });

  console.log( JSON.parse(response.choices[0].message.function_call.arguments));
res.status(200).send({"data":JSON.parse(response.choices[0].message.function_call.arguments)});


  // console.log("ChatGPT says:", chatCompletion.choices[0].message.content);
} catch (error) {
  console.error("Error from OpenAI:", error);
}


});

app.get('/userprofile/:id', authMiddleware, async (req, res) => {
  const user = await db.collection('users').findOne({ _id: new ObjectId(req.params.id) }, { projection: { name: 1, mobilenumber: 1, email: 1 } });
  if (!user) return res.status(404).json({ error: 'User not found' });
  res.json(user);
});

app.post('/addfriend', authMiddleware, async (req, res) => {
  const { targetId } = req.body;

  if (!targetId) {
    return res.status(400).json({ error: 'targetId is required in request body' });
  }

  try {
    await db.collection('users').updateOne(
      { _id: new ObjectId(targetId) },
      { $addToSet: { friendRequests: req.userId } }
    );
    res.json({ message: 'Friend request sent' });
  } catch (err) {
    console.error('Error adding friend:', err);
    res.status(500).json({ error: 'Failed to send friend request' });
  }
});

app.post('/acceptfriend', authMiddleware, async (req, res) => {
  const { senderId } = req.body;

  if (!senderId) {
    return res.status(400).json({ error: 'senderId is required in request body' });
  }

  try {
    await db.collection('users').updateOne(
      { _id: new ObjectId(req.userId) },
      {
        $pull: { friendRequests: senderId },
        $addToSet: { friends: senderId }
      }
    );

    await db.collection('users').updateOne(
      { _id: new ObjectId(senderId) },
      {
        $addToSet: { friends: req.userId }
      }
    );

    res.json({ message: 'Friend request accepted' });
  } catch (err) {
    console.error('Error accepting friend request:', err);
    res.status(500).json({ error: 'Failed to accept friend request' });
  }
});


app.get('/getfriendrequests', authMiddleware, async (req, res) => {
  const user = await db.collection('users').findOne({ _id: new ObjectId(req.userId) });
  const friendRequests = await db.collection('users').find({ _id: { $in: user.friendRequests.map(id => new ObjectId(id)) } }).project({ name: 1, fullname: 1 ,bio:1}).toArray();
  res.json(friendRequests);
});


app.get('/getuserprofile', authMiddleware, async (req, res) => {
  const user = await db.collection('users').findOne({ _id: new ObjectId(req.userId) }, { projection: { bio: 1, email: 1, fullname: 1 } });
  if (!user) return res.status(404).json({ error: 'User not found' });
  res.json(user);
});

app.get('/getfriends', authMiddleware, async (req, res) => {
  const user = await db.collection('users').findOne({ _id: new ObjectId(req.userId) });
  const friends = await db.collection('users').find({ _id: { $in: user.friends.map(id => new ObjectId(id)) } }).project({ fullname: 1, bio: 1 ,_id:1,email:1,mobilenumber:1}).toArray();
  res.json(friends);
});



