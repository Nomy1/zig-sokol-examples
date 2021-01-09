# Look At

Key area of interest in this example is in the frame() function. Here we need to rotate the camera and then invert the matrix before sending it to the vertex shader.

```
// create camera position and rotation
const cam_position = zalgebra.vec3{ .x=0., .y=0., .z=-3. };
const rot_deg = get_rotation();

// it rotates on the y-axis
const rot_vec = zalgebra.vec3 { .x=0., .y=1., .z=0. };

var cam_view = zalgebra.mat4.identity();
cam_view = cam_view.translate(cam_position);
cam_view = cam_view.rotate(rot_deg, rot_vec);

// finally invert the camera model matrix to transform it to the view matrix. 
cam_view = cam_view.inv();
```

## How to run

`zig build look_at`