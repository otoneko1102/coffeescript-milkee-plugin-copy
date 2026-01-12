# milkee-plugin-copy

This is a plugin for [milkee](https://www.npmjs.com/package/milkee) (v3.0.0 or later) .

File copy control with various options added.

## Features

- Delete files matching specific patterns from the output directory after compilation
- Glob pattern support (using minimatch)
- Only works when `milkee.options.copy` is enabled

## Requirements

- **milkee v3.0.0 or later** - This plugin requires milkee v3.0.0 or later due to plugin execution timing.

## Usage

### Setup

#### coffee.config.cjs

```js
/** @type {import('@milkee/d').Config} */
const copyExtra = require('milkee-plugin-copy');

module.exports = {
  entry: 'src',
  output: 'dist',
  options: {
    bare: true,
  },
  milkee: {
    options: {
      copy: true,  // Enable file copy control
    },
    plugins: [
      copyExtra({ ignore: ['*.py', 'foo.txt', '*.tmp'] })
    ]
  }
}
```

### Options

- `ignore` (Array): File patterns to delete from output directory using glob patterns

### Run

```sh
milkee
# or
npx milkee
```
