KD.enableLogs()
hd        = document.head || document.getElementsByTagName("head")[0]
timestamp = Date.now()

class AviaryImageEditor extends KDObject
  
  constructor: (options = {}, data) -> 
    
    super options, data
    
    sc        = document.createElement "script"
    sc.type   = "text/javascript"
    sc.id     = "aviary"
    sc.src    = "https://dme0ih8comzn4.cloudfront.net/js/feather.js"
    
    hd.appendChild sc
    
    oldEl     = document.getElementById "avpw_holder"
    document.body.removeChild oldEl if oldEl
    
    sc.onload = =>
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
                  callback   : ->
                    callback()
                    modal.destroy()
                Cancel       :
                  title      : "Cancel"
                  cssClass   : "modal-cancel"
                  callback   : -> modal.destroy()
                      
          modal.addSubView input = new KDHitEnterInputView
            type             : "text"
            cssClass         : "aviary-name-input"
            placeholder      : "Name of your image without extension"
            callback         : ->
              callback()
              modal.destroy()
              
          return no
         
      launchEditor = (id, src) =>
        featherEditor.launch
          image : id
          url   : src
          
        document.getElementById("avpw_save_button")?.setAttribute "href", "#"
        document.getElementById("avpw_apply_container")?.setAttribute "href", "#"
        document.getElementById("avpw_all_effects")?.setAttribute "href", "#"
        document.getElementById("avpw_up_one_level")?.setAttribute "href", "#"
        return no
        
      imgSrc = @getOptions().image or "http://images.aviary.com/imagesv5/feather_default.jpg"
        
      img = new KDCustomHTMLView
        tagName : "img"
        domId   : "image1"
        bind    : "load"
        attributes: 
          src   : imgSrc
        load    : ->
          KD.utils.wait 1500, ->
            $("#avpw_holder").remove()
            launchEditor "image1", imgSrc
      
      img.hide()
      
      view = new KDView
        domId   : "injection_site"
        cssClass: "aviary-view"
        
      appView.addSubView view
      appView.addSubView img

appView.once "FileNeedsToBeOpened", (file) ->
  appView.destroySubViews()
  filePath       = FSHelper.plainPath file.path
  fileName       = FSHelper.getFileNameFromPath file.path
  command        = "mkdir -p Web/.applications ; cp #{filePath} Web/.applications/#{fileName}"
  kiteController = KD.getSingleton "kiteController"
  
  kiteController.run command, (err, res) ->
    new AviaryImageEditor
      image: """http://#{KD.getSingleton("vmController").defaultVmName}/.applications/#{fileName}"""
      
    KD.utils.wait 15000, ->
      kiteController.run "rm Web/.applications/#{fileName}"

appView.emit "ready"

appView.on "KDObjectWillBeDestroyed", ->
  oldScr = document.getElementById "aviary"
  hd.removeChild oldScr if oldScr

new AviaryImageEditor
