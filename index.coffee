KD.enableLogs()

hd      = document.head || document.getElementsByTagName("head")[0]
oldSc   = document.getElementById "aviary"
hd.removeChild oldSc if oldSc

sc      = document.createElement "script"
sc.type = "text/javascript"
sc.id   = "aviary"
sc.src  = "https://dme0ih8comzn4.cloudfront.net/js/feather.js"
sc.onload = => appView.emit "AviaryScriptIsReady"

hd.appendChild sc

appView.on "AviaryScriptIsReady", =>
  
  featherEditor = new Aviary.Feather
    apiKey     : "ZvjDjQU-0E6esjLnDhSntQ"
    apiVersion : 2
    tools      : "all"
    appendTo   : "injection_site"
    noCloseButton: yes
    onSaveButtonClicked : => 
      [meta, base64] = document.getElementById("avpw_canvas_element").toDataURL().split ","
      temp   = FSHelper.createFileFromPath "Sites/fatihacet.kd.io/temp.txt"
      temp.save base64, (err, res) =>
        KD.getSingleton("kiteController").run """base64 -d #{FSHelper.escapeFilePath temp.path} > #{FSHelper.escapeFilePath "Sites/fatihacet.kd.io/a.png"} ; rm #{FSHelper.escapeFilePath temp.path}""", (err, res) =>
          log "saved"
      return false
     
  launchEditor = (id, src) =>
    featherEditor.launch
      image : id
      url   : src
    return no
    
  img = new KDCustomHTMLView
    tagName : "img"
    domId   : 'image1'
    attributes: 
      src : "http://images.aviary.com/imagesv5/feather_default.jpg"
  
  img.hide()
  
  view = new KDView
    domId   : "injection_site"
    
  view.on "viewAppended", =>
    img.on "viewAppended", =>
      KD.utils.wait 1500, =>
        oldEl = document.getElementById "avpw_holder"
        document.body.removeChild oldEl if oldEl
        launchEditor 'image1', 'http://images.aviary.com/imagesv5/feather_default.jpg' 
    
  appView.addSubView view
  appView.addSubView img