const password = ""
const hostname = ""

const fs = require("fs")
const path = require("path")

// setup
const imagePath = path.join(__dirname, "static")
if (!fs.existsSync(imagePath)) {
  fs.mkdirSync(imagePath)
}

// multer
const multer = require("multer")
const upload = multer()

// express server
const express = require("express")
const bodyParser = require("body-parser")
const mime = require("mime-types")

const app = express()
app.use(bodyParser.urlencoded({ extended: false }))

function newId(length, characters = "abcdefghijklmnopqrstuvwxyz") {
   var charactersLength = characters.length

   var result = ""
   for (i = 0; i < length; i++) {
      result += characters.charAt(Math.floor(Math.random() * charactersLength))
   }
   return result
}

app.post("/", upload.single("file"), async (req, res) => {
  if (!req.body.password || req.body.password != password) {
    res.sendStatus(400)
    return
  }

  if (!req.file) {
    res.sendStatus(401)
    console.log("here")
    return
  }

  const imageBasename = path.basename(req.file.originalname)
  let newDirectoryName
  if (req.body.x) {
    newDirectoryName = newId(8, "69xX")
  } else {
    newDirectoryName = newId(8)
  }
  const newDirectoryPath = path.join(imagePath, newDirectoryName)
  fs.mkdir(newDirectoryPath, err => {
    if (err) {
      console.log(err)
      res.sendStatus(500)
      return
    }

    const newImagePath = path.join(newDirectoryPath, imageBasename)
    fs.writeFile(newImagePath, req.file.buffer, err => {
      if (err) {
        console.log(err)
        res.sendStatus(500)
        return
      }
      res.status(200).send(hostname + path.join(newDirectoryName, imageBasename))
    })
  })
})

app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname + "/upload.html"))
})

app.get("/hdc.sh", (req, res) => {
  res.sendFile(path.join(__dirname + "/hdc.sh"))
})

app.use("/", express.static("static"))

const port = process.env.PORT || 3000
app.listen(port, err => {
  if (err) {
    console.log(err)
    process.exit(1)
  }

  console.log(`running on port: ${port}`)
})