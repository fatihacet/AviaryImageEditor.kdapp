KD.enableLogs()

hd        = document.head || document.getElementsByTagName("head")[0]
oldSc     = document.getElementById "aviary"
hd.removeChild oldSc if oldSc

sc        = document.createElement "script"
sc.type   = "text/javascript"
sc.id     = "aviary"
sc.src    = "https://dme0ih8comzn4.cloudfront.net/js/feather.js"
sc.onload = => appView.emit "AviaryScriptIsReady"

hd.appendChild sc

appView.on "AviaryScriptIsReady", =>
  
  featherEditor = new Aviary.Feather
    apiKey     : "ZvjDjQU-0E6esjLnDhSntQ"
    apiVersion : 3
    tools      : "all"
    theme      : "dark"
    appendTo   : "injection_site"
    noCloseButton: yes
    onSaveButtonClicked : => 
      callback = =>
        notification   = new KDNotificationView
          type         : "mini"
          title        : "Saving your image. This may take a few minutes..."
          duration     : 60000
        timestamp      = Date.now()
        kiteController = KD.getSingleton "kiteController"
        [meta, base64] = document.getElementById("avpw_canvas_element").toDataURL().split ","
        kiteController.run """mkdir -p Documents/Aviary""", ->
          tmpBase64    = FSHelper.createFileFromPath "/tmp/#{timestamp}"
          tmpBase64.save base64, (err, res) =>
            kiteController.run """base64 -d #{FSHelper.escapeFilePath tmpBase64.path} > #{FSHelper.escapeFilePath "Documents/Aviary/#{input.getValue()}.png"}""", (err, res) =>
              notification.notificationSetTitle "Your image saved to Documents/Aviary"
              notification.notificationSetTimer 4000
              notification.setClass "success"
              
      modal = new KDModalView
        overlay          : yes
        cssClass         : "modal-with-text"
        title            : "Save your image"
        content          : "<p>Enter a name for your image. It will be saved into Document/Aviary. Remember saving process may take a few minutes..</p>"
        buttons          :
            Save         : 
              title      : "Save"
              cssClass   : "modal-clean-gray"
              callback   : -> callback() and modal.destroy()
            Cancel       :
              title      : "Cancel"
              cssClass   : "modal-cancel"
              callback   : -> modal.destroy()
                  
      modal.addSubView input = new KDHitEnterInputView
        type             : "text"
        cssClass         : "name-input"
        placeholder      : "Name of your image"
        callback         : -> callback() and modal.destroy()
          
      return no
     
  launchEditor = (id, src) =>
    featherEditor.launch
      image : id
      url   : src
      
    document.getElementById("avpw_save_button").setAttribute "href", "#"
    return no
    
  img = new KDCustomHTMLView
    tagName : "img"
    domId   : "image1"
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