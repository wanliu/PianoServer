seconds = 1000
minutes = 60 * seconds
hours = 60 * minutes
days = 24 * hours
months = 30 * days
years = 365 * days
infinity =  1.0 / 0

sections = [
  { '+seconds': [0, 30, '刚刚'] },
  { '+seconds': [31, 59, '一分钟内'] },
  { '+minutes': [1,  3], title: '$mintes分钟之前' },
  { '+hours': [0, 3], title: '$hours 小时前' },
  { '+hours': [4, 24], days: [0, 0], title: '$hours:$minutes' },
  { '+days': [0, 1, '昨天'] },
  { '+days': [1, 2, '前天'] },
  { '+days': [2, 3, '后天'] },
  { '+days': [4, 31], months: [0, 0], title: '$days 日 $hours:$minutes' }
  { '+months': [1, 12], years: [0, 0], title: '$months 月 $hours:$minutes' },
  { '+year': [1, infinity, '$years 年 $months 月 $hours:$minutes'] }
]

TimeItems = ['years', 'months', 'days', 'hours', 'minutes', 'seconds']

OffsetIndex = {
  years: years,
  months: months,
  days: days,
  hours: hours,
  minutes: minutes,
  seconds: seconds
}

@timeago  = (time)->
  if typeof time == 'number'
    time = new Date(time)

  return null unless isDate(time)

  now = new Date()
  timeValues = getTimes(time)
  nowValues = getTimes(now)
  title = null

  for section in sections
    ret = compareSection section, (name, item) ->
      if name[0] == '+'
        name = name[1..-1]
        compareOffsetItem item, name, nowValues, timeValues
      else
        compareTimeItem item, name, nowValues, timeValues

    if ret
      tpl = getSectionTpl(section)
      return title = template(tpl, timeValues)

  unless title?
    section = last(sections)
    template(getSectionTpl(section), timeValues)

getSectionTpl = (section) ->
  firstKey = Object.keys(section)[0];
  if section.title? then section.title else last(section[firstKey])

template = (tpl, context) ->
  TEMPLATE = /\$(\w+)/g

  tpl.replace TEMPLATE, (_, m) ->
    if isFunction(context[m])
      context[m].call(null, m)
    else
      context[m]

compareTimeItem = (item, name, target, compare ) ->
  [min, max, title] = item
  # title = sections['title'] unless title?
  diff = target[name] - compare[name]
  diff >= min and diff <= max

compareOffsetItem = (item, name, target, compare ) ->
  [min, max, title] = item

  diff = (target['time'] * 1.0 - compare['time']) / OffsetIndex[name]

  diff >= min and diff <= max

compareSection = (section, compareHandle) ->
  maxItem = null; minItem = null
  for item in TimeItems
    if section["+#{item}"]?
      name = "+#{item}"
    else if section[item]?
      name = item

    timeItem = section[item] or section["+#{item}"]
    if !maxItem? and timeItem? # 找到最高级的比较符 , year -> second
      maxItem = timeItem

    if maxItem? and !minItem? and timeItem?  # 开始进行比较，看时间是不是在此区间
      [min, max, title] = timeItem
      return false unless compareHandle(name, timeItem)
      # return false unless compareTimeItem(timeItem, nowValues, timeValues)

    if maxItem? and !minItem? and !timeItem? #  比较到最后的条件
      break
  true

getTimes = (time) ->
  {
    years: time.getFullYear(),
    months: time.getMonth(),
    days: time.getDay(),
    hours: time.getHours(),
    minutes: time.getMinutes(),
    seconds: time.getSeconds(),
    time: time.getTime()
  }

isDate = (date) ->
  date instanceof Date && !isNaN(date.valueOf())

isFunction = (functionToCheck) ->
  getType = {};
  functionToCheck and getType.toString.call(functionToCheck) == '[object Function]'

last = (array) ->
  array[array.length - 1]

first = (array) ->
  array[0]
