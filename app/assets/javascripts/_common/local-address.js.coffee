#= require jquery

LOCAL_ADDRESS_STORAGE = 'anonymousAddress'
class @LocalAddress

  getAll: () ->
    @addresses = JSON.parse(localStorage.getItem(LOCAL_ADDRESS_STORAGE) || '[]')

  get: (id) ->
    @getAll()
    for address in @addresses
      return address if address.id == id
    null

  set: (id, address) ->
    @getAll()
    @setHandle(id, address, @update)

  setHandle: (id, address, callback) ->
    for originAddress, i in @addresses
      if originAddress.id == id
        return callback.call(@, id, originAddress, address)

    callback.call(@, id, null, address)


  update: (id, originAddress, address) ->
    address['id'] = id
    if originAddress?
      address = jQuery.extend(originAddress, address)
    else
      @addresses.push(address)

    @save()
    address    


  save: () ->
    if @addresses?
      localStorage.setItem(LOCAL_ADDRESS_STORAGE, JSON.stringify(@addresses))

  @getAll: ()->
    @localAddress ||= new LocalAddress()
    @localAddress.getAll()

  @get: (id)->
    @localAddress ||= new LocalAddress()
    @localAddress.get(id)

  @set: (id, address)->
    @localAddress ||= new LocalAddress()
    @localAddress.set(id, address)
