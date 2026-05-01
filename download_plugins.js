const fs = require("fs");
const https = require("https");
const path = require("path");

const pluginsBase = "https://office-plugins.ziziyi.com/v9/sdkjs-plugins";
const allPlugins = [
  "ai",
  "apertium",
  "autocomplete",
  "bergamot",
  "chess",
  "cvbuilder",
  "datepicker",
  "deepl",
  "doc2md",
  "drawio",
  "easybib",
  "glavred",
  "grammalecte",
  "highlightcode",
  "html",
  "icons",
  "idphoto",
  "insertQR",
  "jitsi",
  "languagetool",
  "marketplace",
  "mathpix",
  "mendeley",
  "news",
  "ocr",
  "onlydraw",
  "photoeditor",
  "pixabay",
  "pomodoro",
  "rainbow",
  "speech",
  "speechrecognition",
  "telegram",
  "termef",
  "textcleaner",
  "texthighlighter",
  "thesaurus",
  "translator",
  "typograf",
  "videoembedder",
  "wordpress",
  "wordscounter",
  "youtube",
  "zhipu",
  "zoom",
  "zotero",
];

const targetDir = path.join(__dirname, "public", "plugins");

// Papka ochish
if (!fs.existsSync(targetDir)) {
  fs.mkdirSync(targetDir, { recursive: true });
}

allPlugins.forEach((plugin) => {
  const pluginPath = path.join(targetDir, plugin);
  if (!fs.existsSync(pluginPath)) fs.mkdirSync(pluginPath);

  const fileUrl = `${pluginsBase}/${plugin}/config.json`;
  const filePath = path.join(pluginPath, "config.json");

  https
    .get(fileUrl, (res) => {
      const fileStream = fs.createWriteStream(filePath);
      res.pipe(fileStream);
      fileStream.on("finish", () => {
        fileStream.close();
        console.log(`Yuklandi: ${plugin}`);
      });
    })
    .on("error", (err) => {
      console.error(`Xato (${plugin}): ${err.message}`);
    });
});
