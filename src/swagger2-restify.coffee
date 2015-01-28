swagger2 = require 'swagger2-utils'
clone = require 'clone'
extend = require 'extend'

module.exports = (server, swaggerDoc, handlers) ->
  # Make sure the supplied swagger document is valid
  valid = swagger2.validate swaggerDoc
  throw swagger2.validationError  if not valid
  
  # Dereference the swagger document
  swaggerDoc = swagger2.dereference swaggerDoc
  
  # Add routes to the server based on the paths portion of the swagger document
  for path, methods of swaggerDoc.paths
    for method, operation of methods
      if not handlers?[operation.operationId]?
        throw new Error "No handler found for operation #{operation.operationId}"

      method = mapMethodToRestify method
      
      # Merge the path parameters and operation parameters into a single object
      pathParameters = path.parameters or {}
      operationParameters = operation.parameters or {}
      combinedParameters = clone pathParameters
      extend true, combinedParameters, operationParameters
      
      # Add the route to the server
      server[method]
        url: restifyPath path
        schema: combinedParameters
      , handlers[operation.operationId]
      
  # Add our validation plugin to the middleware stack
  server.use validatorPlugin
    
mapMethodToRestify = (method) ->
  if method is 'delete' then 'del' else method
    
restifyPath = (path) ->
  path
  .replace '{', ':'
  .replace '}', ''
  
  
validatorPlugin = (req, res, next) ->
  console.log req?.route?.schema?
  next