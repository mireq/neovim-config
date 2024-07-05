;; extends

((identifier) @variable.class
	(#lua-match? @variable.class "^[A-Z].*[a-z]")
	(#not-has-parent? @variable.class call class_definition function)
)

(call
  function: (attribute
              attribute: (identifier) @field))

(call
  function: (attribute
              attribute: (identifier) @function.call_private)
            (#lua-match? @function.call_private "^__.*"))
(call
  function: (identifier) @function.class_construct
 (#lua-match? @function.class_construct "^[A-Z].*[a-z]"))

(call
  function: (attribute
              attribute: (identifier) @function.class_construct)
            (#lua-match? @function.class_construct "^[A-Z].*[a-z]"))

(class_definition
  name: (identifier) @definition.classname)

(class_definition
  superclasses: (argument_list
                  (identifier) @definition.superclasses))

(class_definition
	superclasses: (
		argument_list (attribute
			attribute: (identifier) @definition.superclasses
		)
	)
)

((class_definition
  body: (block
          (expression_statement
            (assignment
              left: (identifier) @attribute))))
 (#lua-match? @attribute "^%l.*$"))
((class_definition
  body: (block
          (expression_statement
            (assignment
              left: (_
                     (identifier) @attribute)))))
 (#lua-match? @attribute "^%l.*$"))

((decorator "@" @definition.decorator)
 (#set! "priority" 101))

(decorator) @definition.decorator
(decorator
  (identifier) @definition.decorator)
(decorator
  (attribute
    attribute: (identifier) @definition.decorator))
(decorator
  (call (identifier) @definition.decorator))
(decorator
  (call (attribute
          attribute: (identifier) @definition.decorator)))

((identifier) @exception.builtin
 (#any-of? @exception.builtin
           "BaseException"
           "BaseExceptionGroup"
           "GeneratorExit"
           "KeyboardInterrupt"
           "SystemExit"
           "Exception"
           "ArithmeticError"
           "FloatingPointError"
           "OverflowError"
           "ZeroDivisionError"
           "AssertionError"
           "AttributeError"
           "BufferError"
           "EOFError"
           "[BaseExceptionGroup]"
           "ImportError"
           "ModuleNotFoundError"
           "LookupError"
           "IndexError"
           "KeyError"
           "MemoryError"
           "NameError"
           "UnboundLocalError"
           "OSError"
           "BlockingIOError"
           "ChildProcessError"
           "ConnectionError"
           "BrokenPipeError"
           "ConnectionAbortedError"
           "ConnectionRefusedError"
           "ConnectionResetError"
           "FileExistsError"
           "FileNotFoundError"
           "InterruptedError"
           "IsADirectoryError"
           "NotADirectoryError"
           "PermissionError"
           "ProcessLookupError"
           "TimeoutError"
           "ReferenceError"
           "RuntimeError"
           "NotImplementedError"
           "RecursionError"
           "StopAsyncIteration"
           "StopIteration"
           "SyntaxError"
           "IndentationError"
           "TabError"
           "SystemError"
           "TypeError"
           "ValueError"
           "UnicodeError"
           "UnicodeDecodeError"
           "UnicodeEncodeError"
           "UnicodeTranslateError"
           "Warning"
           "BytesWarning"
           "DeprecationWarning"
           "EncodingWarning"
           "FutureWarning"
           "ImportWarning"
           "PendingDeprecationWarning"
           "ResourceWarning"
           "RuntimeWarning"
           "SyntaxWarning"
           "UnicodeWarning"
           "UserWarning"))
