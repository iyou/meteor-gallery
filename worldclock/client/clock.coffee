Template.d3_clock.rendered = ->
  contry = @data
  width = 250
  height = 250
  svgContainer = d3.select(".d3_clock.#{contry.name}")
                   .append("svg")
                   .attr('width', width)
                   .attr('height', height)

  # clock
  maxSize = Math.min(width, height)
  offSetX = maxSize/2
  offSetY = offSetX
  pi = Math.PI
  r = maxSize/2 - 40
  scaleSecs  = d3.scale.linear()
                       .domain([1, 60 + 999 / 1000])
                       .range([0, 2 * pi])
  scaleMins  = d3.scale.linear()
                       .domain([0, 59 + 59 / 60])
                       .range([0, 2 * pi])
  scaleHours = d3.scale.linear()
                       .domain([0, 11 + 59 / 60])
                       .range([0, 2 * pi])

  clockGroup = svgContainer.append("g")
                           .attr("transform", "translate(" + offSetX + "," + offSetY + ")")
  # outer circle
  clockGroup.append("circle")
            .attr("r", r)
            .attr("fill", "white")
            .attr("class", "clock outercircle")
            .attr("stroke", "blue")
            .attr("stroke-width", 2)

  # inner circle
  clockGroup.append("circle")
            .attr("r", 6)
            .attr("fill", "black")
            .attr("class", "clock innercircle")

  # tick labels
  tickLabelGroup = svgContainer.append("g")
                               .attr("transform", "translate(" + offSetX + "," + offSetY + ")")
  fontSize = r / 6
  fontFamily = "Helvetica"
  tickLabelGroup.selectAll("text.label")
                .data(d3.range(12))
                .enter()
                .append("text")
                .attr("class", "label")
                .attr("font-size", fontSize)
                .attr("font-family", fontFamily)
                .attr("x", (d, i) -> (r - fontSize)*Math.cos((2*i*0.26)-1.57) )
                .attr("y", (d, i) -> 7+(r- fontSize)*Math.sin((2*i*0.26)-1.57) )
                .attr("fill", "black")
                .attr("text-anchor", "middle")
                .text((d, i) -> if (d==0) then 12 else d )

  # clock label(location)
  clockLabelGroup = svgContainer.append("g")
                                .attr("transform", "translate(" + offSetX + "," + offSetY + ")")
  clockLabelGroup.append("text")
                 .attr("class", "label")
                 .attr("font-size", fontSize+fontSize/5)
                 .attr("font-family", fontFamily)
                 .attr("x", 0)
                 .attr("y", r+fontSize+5)
                 .attr("fill", "black")
                 .attr("text-anchor", "middle")
                 .text(contry.name)

  # digital label
  digitalGroup = svgContainer.append("g")
                             .attr("transform", "translate(" + offSetX + "," + offSetY + ")")
  digitalGroup.append("text")
              .attr("class", "label")
              .attr("font-size", fontSize+5)
              .attr("font-family",fontFamily)
              .attr("class", "digitalLabel #{contry.name}")
              .attr("x", 0)
              .attr("y", -r-5)
              .attr("fill", "black")
              .attr("text-anchor", "middle")

  tickRender = (data) ->
    $(".digitalLabel.#{contry.name}").text(data[3].string)
    clockGroup.selectAll(".clockhand").remove()

    secondArc = d3.svg.arc()
                      .innerRadius(0)
                      .outerRadius(r*0.8)
                      .startAngle((d) -> scaleSecs(d.numeric))
                      .endAngle((d) -> scaleSecs(d.numeric))

    minuteArc = d3.svg.arc()
                      .innerRadius(0)
                      .outerRadius(r*0.7)
                      .startAngle((d) -> scaleMins(d.numeric))
                      .endAngle((d) -> scaleMins(d.numeric))

    hourArc = d3.svg.arc()
                    .innerRadius(0)
                    .outerRadius(r*0.5)
                    .startAngle((d) -> scaleHours(d.numeric % 12))
                    .endAngle((d) -> scaleHours(d.numeric % 12))

    clockGroup.selectAll(".clockhand")
              .data(data)
              .enter()
              .append("path")
              .attr("d", (d) ->
                switch d.unit
                  when "seconds" then secondArc(d)
                  when "minutes" then minuteArc(d)
                  when "hours" then hourArc(d))
              .attr("class", "clockhand")
              .attr("stroke", "black")
              .attr("stroke-width", (d) ->
                switch d.unit
                  when "seconds" then 1
                  when "minutes" then 3
                  when "hours" then 4)
              .attr("fill", "none")
  tickRender(fields(contry.timeZone))
  Meteor.setInterval((-> tickRender(fields(contry.timeZone))), 1000)

fields = (clockTimeOffset = 0) ->
  currentTime = new Date()
  currentTime.setTime(currentTime.getTime() + (clockTimeOffset*60+currentTime.getTimezoneOffset())*60*1000)
  second = currentTime.getSeconds()
  minute = currentTime.getMinutes()
  hour = currentTime.getHours()
  ampm = "a.m"
  min  = if minute < 10 then "0" + minute else minute

  if hour >= 12
    ampm = "p.m"
    # format: 9:35 p.m
    digiStr = (hour-12) + ":" + min + " " + ampm
  else
    digiStr = hour + ":" + min + " " + ampm

  hour += minute / 60
  return [
    { "unit": "seconds", "width": 3, "numeric": second }
    { "unit": "minutes", "width": 6, "numeric": minute }
    { "unit": "hours",   "width": 9, "numeric": hour }
    { "unit": "digital", "numeric": hour, "string": digiStr }
  ]