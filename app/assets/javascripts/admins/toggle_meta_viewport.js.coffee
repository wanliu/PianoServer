@toggleMetaViewportTag = () ->

  metaName = "viewport"
  metaContent = "width=device-width, initial-scale=1, maximum-scale=2, minimum-scale=1, user-scalable=no"
  template = "<meta name=\"#{metaName}\" content=\"#{metaContent}\">"

  tag = null;
  metaTags = document.getElementsByTagName("meta");

  for meta in metaTags
    if meta.getAttribute("name") == metaName && meta.getAttribute("content") == metaContent
      tag = meta
      break

  head = document.getElementsByTagName("head")[0]

  if tag
    head.removeChild(tag)
  else
    tag = document.createElement("meta")
    tag.setAttribute("name", metaName)
    tag.setAttribute("content", metaContent)
    head.appendChild(tag)

