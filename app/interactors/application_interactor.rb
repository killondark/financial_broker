require 'dry-initializer'

class ApplicationInteractor
  include Dry::Monads[:result, :do]
  include Dry::Monads::Do.for(:call)
  extend Dry::Initializer

  def self.call(params = {})
    new(params).call
  end

  def call
    Success()
  end

  private

  def process_error
    yield
  rescue Dry::Monads::Do::Halt => e
    e.result
  rescue StandardError => e
    # TODO: здесь необходимо добавить в Sentry обработку. В данном MVP пропущено.
    Failure(e)
  end
end
