# frozen_string_literal: true

# The exception a block raises, or nil.
def raised
  yield
  nil
rescue Exception => e # rubocop:disable Lint/RescueException
  e
end
