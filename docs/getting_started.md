# Getting Started

## Creating a module

To get started, let's create a module, gleamgen's highest level building block.
Almost all gleam code you'll generate with gleamgen should ultimately be a part
of a module. Modules make heavy use of Gleam's use syntax, so you'll want to
create one in a block or its own function.
The simplest possible module consists of just one component: its end, `module.eof`
```gleam
import gleamgen/module

pub fn main() {
  let mod = {
    module.eof()
  }
}
```

### Adding Content

Let's add something to our module before we convert it into text.
We can create a constant with `module.with_constant`. When used as a use
expression, it takes two parameters: its definition (where we provide its name
`greeting` and set it to public), and its contents (which we set to the string
literal `"hello"`).

```gleam
import gleamgen/expression
import gleamgen/module
import gleamgen/module/definition

pub fn main() {
  let mod = {
    use greeting <- module.with_constant(
      definition.new("greeting") |> definition.with_publicity(True),
      expression.string("hello"),
    )

    module.eof()
  }
}
```
We'll later use the greeting variable on the left side of the use expression to
reference this constant.

### Rendering

First though, let's actually display this text.

```gleam
import gleamgen/expression
import gleamgen/module
import gleamgen/module/definition
import gleamgen/render

pub fn main() {
  let mod = {
    use greeting <- module.with_constant(
      definition.new("greeting") |> definition.with_publicity(True),
      expression.string("hello"),
    )
    module.eof()
  }

  mod
  |> module.render(render.default_context())
  |> render.to_string()
}
```

To do so, we must "render" the module by passing it to `module.render`. The
other argument taken by this function is the render context. In this case, the
default context is perfect, but one could also use create a context with a
custom render config (see [`gleamgen/render`](gleamgen/render.html)).

This returns functions value of the render.Rendered type. This type allows us
to view potential errors in the code generation process. However, here we're
just interested in the output, so we pipe it directly to `render.to_string`.

This will print out the following:
```gleam
pub const greeting = "hello"
```

## Adding a function

Let's make this module more interesting. To define a function, you can use
`module.with_function`.

```gleam
import gleamgen/expression
import gleamgen/function
import gleamgen/module
import gleamgen/module/definition
import gleamgen/parameter
import gleamgen/render
import gleamgen/type_

pub fn main() {
  let mod = {
    use greeting <- module.with_constant(
      definition.new("greeting") |> definition.with_publicity(True),
      expression.string("hello"),
    )

    use greet_user <- module.with_function(
      definition.new("greet_user"),
      function.new1(
        param1: parameter.new("user", type_.string),
        returns: type_.string,
        handler: fn(user) {
          expression.concat_string(
            expression.string("hello "), 
            user,
          )
        },
      ),
    )

    module.eof()
  }

  mod
  |> module.render(render.default_context())
  |> render.to_string()
}
```
Functions are defined using the same definition type as constants. However,
they also contain the information about the function itself. Here, we create
this with [`function.new1`](gleamgen/function.html#new1) to specify our
function takes exactly one parameter.

We define that parameter using the parameter type (which we could also use to
add labels), where we provide the parameter name and type.

After specifiying the return type, we start actually defining the function in
the handler argument. We can treat this exactly like the function we're
defining: its only argument is the parameter we specified earlier.
```gleam
fn(user) {
  expression.concat_string(
    expression.string("hello "), 
    user,
  )
}
```

But wait! We already defined a greeting earlier. Let's use that instead (and
add a space to it to ensure legibility). This is as sample as using the
greeting variable defined by our use expression earlier.

```gleam
fn(user) {
  expression.concat_string(
    expression.concat_string(greeting, expression.string(" ")),
    user,
  )
}
```

This generates the following code:
```gleam
pub const greeting = "hello"

fn greet_user(user: String) -> String {
  greeting <> " " <> user
}
```

## Type Safety

This function definition is actually already type safe! Here, gleamgen uses
phantom types to ensure that the function returns a string. To be confident in
this, we ensure that the expression returned by the function is of type
Expression(String), matching the return type type_.GeneratedType(String).

Try changing the parameter or return type of this example. You'll get a
compile-time type error!

Of course, generating custom code by nature requires flexibility, so there are
times this system can be an impediment. For that gleamgen includes a number of
"dynamic" functions, which allow you to avoid the phantom type checking or
create functions or custom tyeps with a variable number of parameters.

## Importing

Now, let's print this greeting! To do that, we need to be able to import the
`gleam/io` module. With gleamgen, this is simple:
```gleam
use io_mod <- module.with_import(import_.new(["gleam", "io"]))
```

`io_mod` contains a stored reference to this import. If we never use it, by
default this import statement will not be rendered in the final code. This is
useful if only certain code paths make use of a module.

To use the module reference here, we can use
[`import_.value_of_type`](gleamgen/import_.html#value_of_type).
This function takes the name of what we want to import (println), and its type.
io.println has a type of `fn(String) -> Nil`, which we can represent with
`type_.function1(type_.string, type_.nil)`. However, because we're referencing
an existing function, here it would be cleaner to use
[`type_.reference`](gleamgen/type_.html#reference)

With this, we can create a simple hello world program: 
```gleam
// ..
let io_println =
  import_.value_of_type(io_mod, "println", type_.reference(io.println))
use _main <- module.with_function(
  definition.new("main") |> definition.with_publicity(True),
  function.new0(returns: type_.nil, handler: fn() {
    expression.call1(io_println, expression.string("Hello, World!"))
  }),
)
// ..
```

## Blocks

Let's say we want to store a name in a local variable before we generate a
reference to it.
We can do this with the
[`block.with_let_declaration`](gleamgen/expresion/block.html#with_let_declaration)
function.
```gleam
let main_function = fn() {
  use name <- block.with_let_declaration(
    "name",
    expression.string("Viktor"),
  )
  todo as "the rest of the function"
} 
```

Let's also make a variable for the full greeting, and add a comment describing
it.
```gleam
let main_function = fn() {
  use name <- block.with_let_declaration(
    "name",
    expression.string("Viktor"),
  )
  use <- block.with_comments(["A greeting for the given name"])
  use greeting <- block.with_let_declaration(
    "greeting",
    expression.call1(greet_user, name),
  )
  todo as "the rest of the function"
}
```

With that, we can add a main function to our code, including an extra empty
line before the print function. Here's the final code:
```gleam
import gleam/io
import gleamgen/expression
import gleamgen/expression/block
import gleamgen/function
import gleamgen/import_
import gleamgen/module
import gleamgen/module/definition
import gleamgen/parameter
import gleamgen/render
import gleamgen/type_

pub fn main() {
  let mod = {
    use io_mod <- module.with_import(import_.new(["gleam", "io"]))
    use greeting <- module.with_constant(
      definition.new("greeting") |> definition.with_publicity(True),
      expression.string("hello"),
    )

    use greet_user <- module.with_function(
      definition.new("greet_user"),
      function.new1(
        param1: parameter.new("user", type_.string),
        returns: type_.string,
        handler: fn(user) {
          expression.concat_string(
            expression.concat_string(greeting, expression.string(" ")),
            user,
          )
        },
      ),
    )

    let io_println =
      import_.value_of_type(io_mod, "println", type_.reference(io.println))

    let main_function = fn() {
      use name <- block.with_let_declaration(
        "name",
        expression.string("Viktor"),
      )
      use <- block.with_comments(["A greeting for the given name"])
      use greeting <- block.with_let_declaration(
        "greeting",
        expression.call1(greet_user, name),
      )
      use <- block.with_empty_line()
      expression.call1(io_println, greeting)
    }

    use _main <- module.with_function(
      definition.new("main") |> definition.with_publicity(True),
      function.new0(returns: type_.nil, handler: main_function),
    )

    module.eof()
  }

  mod
  |> module.render(render.default_context())
  |> render.to_string()
}
```

And here's the code that ultimately generates:
```gleam
import gleam/io

pub const greeting = "hello"

fn greet_user(user: String) -> String {
  greeting <> " " <> user
}

pub fn main() -> Nil {
  let name = "Viktor"
  // A greeting for the given name
  let greeting = greet_user(name)

  io.println(greeting)
}
```

## Next Steps

Checkout the [examples folder](https://github.com/BrewingWeasel/gleamgen/tree/main/examples) or gleamgen's tests!
