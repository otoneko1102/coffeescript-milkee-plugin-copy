fs = require 'fs'
path = require 'path'
{ minimatch } = require 'minimatch'
consola = require 'consola'

pkg = require '../package.json'
PREFIX = "[#{pkg.name}]"

# Create a custom logger with prefix
c = {}
for method in ['log', 'info', 'success', 'warn', 'error', 'debug', 'start', 'box']
  do (method) ->
    c[method] = (args...) ->
      if typeof args[0] is 'string'
        args[0] = "#{PREFIX} #{args[0]}"
      consola[method] args...

# Check if file matches any pattern in the ignore list
isIgnored = (file, patterns) ->
  for pattern in patterns
    if minimatch(file, pattern)
      return true
  return false

# Recursively delete files matching patterns from a directory
deleteIgnoredFiles = (dir, patterns, baseDir = dir, deletedFiles = []) ->
  try
    if fs.existsSync(dir)
      entries = fs.readdirSync(dir)
      for entry in entries
        fullPath = path.join(dir, entry)
        relPath = path.relative(baseDir, fullPath).replace(/\\/g, '/')
        stat = fs.statSync(fullPath)

        if stat.isDirectory()
          deleteIgnoredFiles(fullPath, patterns, baseDir, deletedFiles)
        else
          if isIgnored(relPath, patterns)
            fs.unlinkSync(fullPath)
            deletedFiles.push(relPath)
    else
      c.error "Output directory does not exist: #{dir}"
  catch err
    c.error "Error processing directory: #{err.message}"

  return deletedFiles

# Main plugin function
pluginHandler = (compilationResult, patterns = []) ->
  { config, compiledFiles, stdout, stderr } = compilationResult

  # Check if copy option is enabled
  isCopyEnabled = config?.milkee?.options?.copy is true

  if not isCopyEnabled
    c.info "Copy option is not enabled. Plugin skipped."
    return

  # Get ignore patterns
  ignorePatterns = patterns or []

  if ignorePatterns.length is 0
    c.info "No ignore patterns specified."
    return

  # Get output directory from config
  outputDir = config?.output
  if not outputDir
    c.error "Output directory not specified in config."
    return

  # Convert to absolute path if relative
  if not path.isAbsolute(outputDir)
    outputDir = path.resolve(outputDir)

  if not fs.existsSync(outputDir)
    c.error "Output directory does not exist: #{outputDir}"
    return

  # Delete ignored files
  deletedFiles = deleteIgnoredFiles(outputDir, ignorePatterns)

  if deletedFiles.length > 0
    c.success "Deleted #{deletedFiles.length} file(s):"
    for file in deletedFiles
      c.log "  - #{file}"
  else
    c.info "No files matched the ignore patterns."

# Plugin factory function
module.exports = (options = {}) ->
  ignorePatterns = options?.ignore or []
  return (compilationResult) ->
    pluginHandler(compilationResult, ignorePatterns)
