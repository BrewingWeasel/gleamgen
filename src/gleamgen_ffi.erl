-module(gleamgen_ffi).
-export([identity/1, get_function_name/1, get_pattern_output/1]).

identity(X) -> X.

get_function_name(Funct) ->
  {name, Name} = erlang:fun_info(Funct, name),
  erlang:atom_to_binary(Name).

get_pattern_output({_, _, nil}) -> {error, nil};
get_pattern_output({_, _, X}) -> {ok, X}.
