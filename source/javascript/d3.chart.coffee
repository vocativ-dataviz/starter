###! d3.chart - v0.2.1
#  License: MIT Expat
#  Date: 2014-06-24
###

((window) ->
  # extend
  # Borrowed from Underscore.js

  extend = (object) ->
    argsIndex = undefined
    argsLength = undefined
    iteratee = undefined
    key = undefined
    if !object
      return object
    argsLength = arguments.length
    argsIndex = 1
    while argsIndex < argsLength
      iteratee = arguments[argsIndex]
      if iteratee
        for key of iteratee
          `key = key`
          object[key] = iteratee[key]
      argsIndex++
    object

  'use strict'

  ###jshint unused: false ###

  d3 = window.d3
  hasOwnProp = Object.hasOwnProperty

  d3cAssert = (test, message) ->
    if test
      return
    throw new Error('[d3.chart] ' + message)
    return

  d3cAssert d3, 'd3.js is required'
  d3cAssert typeof d3.version == 'string' and d3.version.match(/^3/), 'd3.js version 3 is required'
  'use strict'
  lifecycleRe = /^(enter|update|merge|exit)(:transition)?$/

  ###*
  # Create a layer using the provided `base`. The layer instance is *not*
  # exposed to d3.chart users. Instead, its instance methods are mixed in to the
  # `base` selection it describes; users interact with the instance via these
  # bound methods.
  #
  # @private
  # @constructor
  #
  # @param {d3.selection} base The containing DOM node for the layer.
  ###

  Layer = (base) ->
    d3cAssert base, 'Layers must be initialized with a base.'
    @_base = base
    @_handlers = {}
    return

  ###*
  # Invoked by {@link Layer#draw} to join data with this layer's DOM nodes. This
  # implementation is "virtual"--it *must* be overridden by Layer instances.
  #
  # @param {Array} data Value passed to {@link Layer#draw}
  ###

  Layer::dataBind = ->
    d3cAssert false, 'Layers must specify a `dataBind` method.'
    return

  ###*
  # Invoked by {@link Layer#draw} in order to insert new DOM nodes into this
  # layer's `base`. This implementation is "virtual"--it *must* be overridden by
  # Layer instances.
  ###

  Layer::insert = ->
    d3cAssert false, 'Layers must specify an `insert` method.'
    return

  ###*
  # Subscribe a handler to a "lifecycle event". These events (and only these
  # events) are triggered when {@link Layer#draw} is invoked--see that method
  # for more details on lifecycle events.
  #
  # @param {String} eventName Identifier for the lifecycle event for which to
  #        subscribe.
  # @param {Function} handler Callback function
  #
  # @returns {d3.selection} Reference to the layer's base.
  ###

  Layer::on = (eventName, handler, options) ->
    options = options or {}
    d3cAssert lifecycleRe.test(eventName), 'Unrecognized lifecycle event name specified to `Layer#on`: \'' + eventName + '\'.'
    if !(eventName in @_handlers)
      @_handlers[eventName] = []
    @_handlers[eventName].push
      callback: handler
      chart: options.chart or null
    @_base

  ###*
  # Unsubscribe the specified handler from the specified event. If no handler is
  # supplied, remove *all* handlers from the event.
  #
  # @param {String} eventName Identifier for event from which to remove
  #        unsubscribe
  # @param {Function} handler Callback to remove from the specified event
  #
  # @returns {d3.selection} Reference to the layer's base.
  ###

  Layer::off = (eventName, handler) ->
    handlers = @_handlers[eventName]
    idx = undefined
    d3cAssert lifecycleRe.test(eventName), 'Unrecognized lifecycle event name specified to `Layer#off`: \'' + eventName + '\'.'
    if !handlers
      return @_base
    if arguments.length == 1
      handlers.length = 0
      return @_base
    idx = handlers.length - 1
    while idx > -1
      if handlers[idx].callback == handler
        handlers.splice idx, 1
      --idx
    @_base

  ###*
  # Render the layer according to the input data: Bind the data to the layer
  # (according to {@link Layer#dataBind}, insert new elements (according to
  # {@link Layer#insert}, make lifecycle selections, and invoke all relevant
  # handlers (as attached via {@link Layer#on}) with the lifecycle selections.
  #
  # - update
  # - update:transition
  # - enter
  # - enter:transition
  # - exit
  # - exit:transition
  #
  # @param {Array} data Data to drive the rendering.
  ###

  Layer::draw = (data) ->
    bound = undefined
    entering = undefined
    events = undefined
    selection = undefined
    handlers = undefined
    eventName = undefined
    idx = undefined
    len = undefined
    bound = @dataBind.call(@_base, data)
    # Although `bound instanceof d3.selection` is more explicit, it fails
    # in IE8, so we use duck typing to maintain compatability.
    d3cAssert bound and bound.call == d3.selection::call, 'Invalid selection defined by `Layer#dataBind` method.'
    d3cAssert bound.enter, 'Layer selection not properly bound.'
    entering = bound.enter()
    entering._chart = @_base._chart
    events = [
      {
        name: 'update'
        selection: bound
      }
      {
        name: 'enter'
        selection: @insert.bind(entering)
      }
      {
        name: 'merge'
        selection: bound
      }
      {
        name: 'exit'
        selection: bound.exit.bind(bound)
      }
    ]
    i = 0
    l = events.length
    while i < l
      eventName = events[i].name
      selection = events[i].selection
      # Some lifecycle selections are expressed as functions so that
      # they may be delayed.
      if typeof selection == 'function'
        selection = selection()
      if selection.empty()
                ++i
        continue
      # Although `selection instanceof d3.selection` is more explicit,
      # it fails in IE8, so we use duck typing to maintain
      # compatability.
      d3cAssert selection and selection.call == d3.selection::call, 'Invalid selection defined for \'' + eventName + '\' lifecycle event.'
      handlers = @_handlers[eventName]
      if handlers
                idx = 0
        len = handlers.length
        while idx < len
          # Attach a reference to the parent chart so the selection"s
          # `chart` method will function correctly.
          selection._chart = handlers[idx].chart or @_base._chart
          selection.call handlers[idx].callback
          ++idx
      handlers = @_handlers[eventName + ':transition']
      if handlers and handlers.length
        selection = selection.transition()
                idx = 0
        len = handlers.length
        while idx < len
          selection._chart = handlers[idx].chart or @_base._chart
          selection.call handlers[idx].callback
          ++idx
      ++i
    return

  'use strict'

  ###*
  # Create a new layer on the d3 selection from which it is called.
  #
  # @static
  #
  # @param {Object} [options] Options to be forwarded to {@link Layer|the Layer
  #        constructor}
  # @returns {d3.selection}
  ###

  d3.selection::layer = (options) ->
    layer = new Layer(this)
    eventName = undefined
    # Set layer methods (required)
    layer.dataBind = options.dataBind
    layer.insert = options.insert
    # Bind events (optional)
    if 'events' in options
      for eventName of options.events
        `eventName = eventName`
        layer.on eventName, options.events[eventName]
    # Mix the public methods into the D3.js selection (bound appropriately)

    @on = ->
      layer.on.apply layer, arguments

    @off = ->
      layer.off.apply layer, arguments

    @draw = ->
      layer.draw.apply layer, arguments

    this

  'use strict'

  ###*
  # Call the {@Chart#initialize} method up the inheritance chain, starting with
  # the base class and continuing "downward".
  #
  # @private
  ###

  initCascade = (instance, args) ->
    ctor = @constructor
    sup = ctor.__super__
    if sup
      initCascade.call sup, instance, args
    # Do not invoke the `initialize` method on classes further up the
    # prototype chain (again).
    if hasOwnProp.call(ctor.prototype, 'initialize')
      @initialize.apply instance, args
    return

  ###*
  # Call the `transform` method down the inheritance chain, starting with the
  # instance and continuing "upward". The result of each transformation should
  # be supplied as input to the next.
  #
  # @private
  ###

  transformCascade = (instance, data) ->
    ctor = @constructor
    sup = ctor.__super__
    # Unlike `initialize`, the `transform` method has significance when
    # attached directly to a chart instance. Ensure that this transform takes
    # first but is not invoked on later recursions.
    if this == instance and hasOwnProp.call(this, 'transform')
      data = @transform(data)
    # Do not invoke the `transform` method on classes further up the prototype
    # chain (yet).
    if hasOwnProp.call(ctor.prototype, 'transform')
      data = ctor::transform.call(instance, data)
    if sup
      data = transformCascade.call(sup, instance, data)
    data

  ###*
  # Create a d3.chart
  #
  # @param {d3.selection} selection The chart's "base" DOM node. This should
  #        contain any nodes that the chart generates.
  # @param {mixed} chartOptions A value for controlling how the chart should be
  #        created. This value will be forwarded to {@link Chart#initialize}, so
  #        charts may define additional properties for consumers to modify their
  #        behavior during initialization.
  #
  # @constructor
  ###

  Chart = (selection, chartOptions) ->
    @base = selection
    @_layers = {}
    @_attached = {}
    @_events = {}
    if chartOptions and chartOptions.transform
      @transform = chartOptions.transform
    initCascade.call this, this, [ chartOptions ]
    return

  ###*
  # Set up a chart instance. This method is intended to be overridden by Charts
  # authored with this library. It will be invoked with a single argument: the
  # `options` value supplied to the {@link Chart|constructor}.
  #
  # For charts that are defined as extensions of other charts using
  # `Chart.extend`, each chart's `initilize` method will be invoked starting
  # with the "oldest" ancestor (see the private {@link initCascade} function for
  # more details).
  ###

  Chart::initialize = ->

  ###*
  # Remove a layer from the chart.
  #
  # @param {String} name The name of the layer to remove.
  #
  # @returns {Layer} The layer removed by this operation.
  ###

  Chart::unlayer = (name) ->
    layer = @layer(name)
    delete @_layers[name]
    delete layer._chart
    layer

  ###*
  # Interact with the chart's {@link Layer|layers}.
  #
  # If only a `name` is provided, simply return the layer registered to that
  # name (if any).
  #
  # If a `name` and `selection` are provided, treat the `selection` as a
  # previously-created layer and attach it to the chart with the specified
  # `name`.
  #
  # If all three arguments are specified, initialize a new {@link Layer} using
  # the specified `selection` as a base passing along the specified `options`.
  #
  # The {@link Layer.draw} method of attached layers will be invoked
  # whenever this chart's {@link Chart#draw} is invoked and will receive the
  # data (optionally modified by the chart's {@link Chart#transform} method.
  #
  # @param {String} name Name of the layer to attach or retrieve.
  # @param {d3.selection|Layer} [selection] The layer's base or a
  #        previously-created {@link Layer}.
  # @param {Object} [options] Options to be forwarded to {@link Layer|the Layer
  #        constructor}
  #
  # @returns {Layer}
  ###

  Chart::layer = (name, selection, options) ->
    layer = undefined
    if arguments.length == 1
      return @_layers[name]
    # we are reattaching a previous layer, which the
    # selection argument is now set to.
    if arguments.length == 2
      if typeof selection.draw == 'function'
        selection._chart = this
        @_layers[name] = selection
        return @_layers[name]
      else
        d3cAssert false, 'When reattaching a layer, the second argument ' + 'must be a d3.chart layer'
    layer = selection.layer(options)
    @_layers[name] = layer
    selection._chart = this
    layer

  ###*
  # Register or retrieve an "attachment" Chart. The "attachment" chart's `draw`
  # method will be invoked whenever the containing chart's `draw` method is
  # invoked.
  #
  # @param {String} attachmentName Name of the attachment
  # @param {Chart} [chart] d3.chart to register as a mix in of this chart. When
  #        unspecified, this method will return the attachment previously
  #        registered with the specified `attachmentName` (if any).
  #
  # @returns {Chart} Reference to this chart (chainable).
  ###

  Chart::attach = (attachmentName, chart) ->
    if arguments.length == 1
      return @_attached[attachmentName]
    @_attached[attachmentName] = chart
    chart

  ###*
  # Update the chart's representation in the DOM, drawing all of its layers and
  # any "attachment" charts (as attached via {@link Chart#attach}).
  #
  # @param {Object} data Data to pass to the {@link Layer#draw|draw method} of
  #        this cart's {@link Layer|layers} (if any) and the {@link
  #        Chart#draw|draw method} of this chart's attachments (if any).
  ###

  Chart::draw = (data) ->
    layerName = undefined
    attachmentName = undefined
    attachmentData = undefined
    data = transformCascade.call(this, this, data)
    for layerName of @_layers
      `layerName = layerName`
      @_layers[layerName].draw data
    for attachmentName of @_attached
      `attachmentName = attachmentName`
      if @demux
        attachmentData = @demux(attachmentName, data)
      else
        attachmentData = data
      @_attached[attachmentName].draw attachmentData
    return

  ###*
  # Function invoked with the context specified when the handler was bound (via
  # {@link Chart#on} {@link Chart#once}).
  #
  # @callback ChartEventHandler
  # @param {...*} arguments Invoked with the arguments passed to {@link
  #         Chart#trigger}
  ###

  ###*
  # Subscribe a callback function to an event triggered on the chart. See {@link
  # Chart#once} to subscribe a callback function to an event for one occurence.
  #
  # @param {String} name Name of the event
  # @param {ChartEventHandler} callback Function to be invoked when the event
  #        occurs
  # @param {Object} [context] Value to set as `this` when invoking the
  #        `callback`. Defaults to the chart instance.
  #
  # @returns {Chart} A reference to this chart (chainable).
  ###

  Chart::on = (name, callback, context) ->
    events = @_events[name] or (@_events[name] = [])
    events.push
      callback: callback
      context: context or this
      _chart: this
    this

  ###*
  # Subscribe a callback function to an event triggered on the chart. This
  # function will be invoked at the next occurance of the event and immediately
  # unsubscribed. See {@link Chart#on} to subscribe a callback function to an
  # event indefinitely.
  #
  # @param {String} name Name of the event
  # @param {ChartEventHandler} callback Function to be invoked when the event
  #        occurs
  # @param {Object} [context] Value to set as `this` when invoking the
  #        `callback`. Defaults to the chart instance
  #
  # @returns {Chart} A reference to this chart (chainable)
  ###

  Chart::once = (name, callback, context) ->
    self = this

    once = ->
      self.off name, once
      callback.apply this, arguments
      return

    @on name, once, context

  ###*
  # Unsubscribe one or more callback functions from an event triggered on the
  # chart. When no arguments are specified, *all* handlers will be unsubscribed.
  # When only a `name` is specified, all handlers subscribed to that event will
  # be unsubscribed. When a `name` and `callback` are specified, only that
  # function will be unsubscribed from that event. When a `name` and `context`
  # are specified (but `callback` is omitted), all events bound to the given
  # event with the given context will be unsubscribed.
  #
  # @param {String} [name] Name of the event to be unsubscribed
  # @param {ChartEventHandler} [callback] Function to be unsubscribed
  # @param {Object} [context] Contexts to be unsubscribe
  #
  # @returns {Chart} A reference to this chart (chainable).
  ###

  Chart::off = (name, callback, context) ->
    names = undefined
    n = undefined
    events = undefined
    event = undefined
    i = undefined
    j = undefined
    # remove all events
    if arguments.length == 0
      for name of @_events
        `name = name`
        @_events[name].length = 0
      return this
    # remove all events for a specific name
    if arguments.length == 1
      events = @_events[name]
      if events
        events.length = 0
      return this
    # remove all events that match whatever combination of name, context
    # and callback.
    names = if name then [ name ] else Object.keys(@_events)
    i = 0
    while i < names.length
      n = names[i]
      events = @_events[n]
      j = events.length
      while j--
        event = events[j]
        if callback and callback == event.callback or context and context == event.context
          events.splice j, 1
      i++
    this

  ###*
  # Publish an event on this chart with the given `name`.
  #
  # @param {String} name Name of the event to publish
  # @param {...*} arguments Values with which to invoke the registered
  #        callbacks.
  #
  # @returns {Chart} A reference to this chart (chainable).
  ###

  Chart::trigger = (name) ->
    args = Array::slice.call(arguments, 1)
    events = @_events[name]
    i = undefined
    ev = undefined
    if events != undefined
      i = 0
      while i < events.length
        ev = events[i]
        ev.callback.apply ev.context, args
        i++
    this

  ###*
  # Create a new {@link Chart} constructor with the provided options acting as
  # "overrides" for the default chart instance methods. Allows for basic
  # inheritance so that new chart constructors may be defined in terms of
  # existing chart constructors. Based on the `extend` function defined by
  # {@link http://backbonejs.org/|Backbone.js}.
  #
  # @static
  #
  # @param {String} name Identifier for the new Chart constructor.
  # @param {Object} protoProps Properties to set on the new chart's prototype.
  # @param {Object} staticProps Properties to set on the chart constructor
  #        itself.
  #
  # @returns {Function} A new Chart constructor
  ###

  Chart.extend = (name, protoProps, staticProps) ->
    parent = this
    child = undefined
    # The constructor function for the new subclass is either defined by
    # you (the "constructor" property in your `extend` definition), or
    # defaulted by us to simply call the parent's constructor.
    if protoProps and hasOwnProp.call(protoProps, 'constructor')
      child = protoProps.constructor
    else

      child = ->
        parent.apply this, arguments

    # Add static properties to the constructor function, if supplied.
    extend child, parent, staticProps
    # Set the prototype chain to inherit from `parent`, without calling
    # `parent`'s constructor function.

    Surrogate = ->
      @constructor = child
      return

    Surrogate.prototype = parent.prototype
    child.prototype = new Surrogate
    # Add prototype properties (instance properties) to the subclass, if
    # supplied.
    if protoProps
      extend child.prototype, protoProps
    # Set a convenience property in case the parent's prototype is needed
    # later.
    child.__super__ = parent.prototype
    Chart[name] = child
    child

  'use strict'

  ###*
  # Create a new chart constructor or return a previously-created chart
  # constructor.
  #
  # @static
  #
  # @param {String} name If no other arguments are specified, return the
  #        previously-created chart with this name.
  # @param {Object} protoProps If specified, this value will be forwarded to
  #        {@link Chart.extend} and used to create a new chart.
  # @param {Object} staticProps If specified, this value will be forwarded to
  #        {@link Chart.extend} and used to create a new chart.
  ###

  d3.chart = (name) ->
    if arguments.length == 0
      return Chart
    else if arguments.length == 1
      return Chart[name]
    Chart.extend.apply Chart, arguments

  ###*
  # Instantiate a chart or return the chart that the current selection belongs
  # to.
  #
  # @static
  #
  # @param {String} [chartName] The name of the chart to instantiate. If the
  #        name is unspecified, this method will return the chart that the
  #        current selection belongs to.
  # @param {mixed} options The options to use when instantiated the new chart.
  #        See {@link Chart} for more information.
  ###

  d3.selection::chart = (chartName, options) ->
    # Without an argument, attempt to resolve the current selection's
    # containing d3.chart.
    if arguments.length == 0
      return @_chart
    ChartCtor = Chart[chartName]
    d3cAssert ChartCtor, 'No chart registered with name \'' + chartName + '\''
    new ChartCtor(this, options)

  # Implement the zero-argument signature of `d3.selection.prototype.chart`
  # for all selection types.

  d3.selection.enter::chart = ->
    @_chart

  d3.transition::chart = d3.selection.enter::chart
  return
) this

# ---
# generated by js2coffee 2.0.3