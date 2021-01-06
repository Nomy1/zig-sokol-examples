# Wireframe

## How to run

`zig build wireframe`

Renders a wireframe to the screen. This is almost identicle to quad except that we set the primitive type to .LINES in the pipeline description.

```
.primitive_type = .LINES,
```