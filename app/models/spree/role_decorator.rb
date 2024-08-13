module Spree::RoleDecorator
  def self.prepended(base)
    base.define_method :affiliate do
      find_or_create_by(name: :affiliate)
    end
  end
end

Spree::Role.prepend(Spree::RoleDecorator)
