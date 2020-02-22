const password = ""
const hostname = "localhost:3000/"

const fs = require("fs")
const path = require("path")

// setup
const imagePath = path.join(__dirname + "/images")
if (!fs.existsSync(imagePath)) {
  fs.mkdirSync(imagePath)
}

// multer
const multer = require("multer")
const upload = multer({
  limits: {
    fileSize: 4 * 1024 * 1024,
  }
})

// express server
const express = require("express")
const bodyParser = require("body-parser")
const mime = require("mime-types")

const app = express()
app.use(bodyParser.urlencoded({ extended: false }))

function newId(length) {
   var characters = "abcdefghijklmnopqrstuvwxyz"
   var charactersLength = characters.length

   var result = ""
   for (i = 0; i < length; i++) {
      result += characters.charAt(Math.floor(Math.random() * charactersLength))
   }
   return result
}

app.post("/post", upload.single("image"), async (req, res) => {
  if (!req.body.password) {
    res.sendStatus(400)
    return
  }

  if (req.body.password != password) {
    res.sendStatus(400)
    return
  }

  if (!req.file) {
    res.sendStatus(401)
    console.log("here")
    return
  }
  let extension = path.extname(req.file.originalname)
  let id = newId(4) + extension
  fs.writeFile(path.join(imagePath + "/" + id), req.file.buffer, (err) => {
    if (err) {
      console.log(err)
      res.status(500).send("err!!!")
      return
    }

    res.status(200).send(hostname + id)
  })
})

app.get("/upload", (req, res) => {
  res.sendFile(path.join(__dirname + "/upload.html"))
})

app.get("/:imageId", async (req, res) => {
  fs.readFile(path.join(imagePath + "/" + req.params.imageId), (err, data) => {
    if (err) {
      res.sendStatus(404)
      return
    }

    res.set("Content-Type", mime.contentType(req.params.imageId))
    res.send(data)
  })
})

const port = process.env.PORT || 3000
app.listen(port, err => {
  if (err) {
    console.log(err)
    process.exit(1)
  }

  console.log(`running on port: ${port}`)
})