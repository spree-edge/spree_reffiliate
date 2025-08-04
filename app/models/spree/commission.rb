module Spree
  class Commission < Spree::Base
    has_one :commission_transaction, class_name: 'Spree::CommissionTransaction', dependent: :restrict_with_error
    belongs_to :affiliate, class_name: 'Spree::Affiliate'

    validate :cannot_mark_unpaid

    self.whitelisted_ransackable_associations = %w[affiliate]
    self.whitelisted_ransackable_attributes =  %w[paid]

    define_model_callbacks :mark_paid, only: :after

    after_mark_paid :lock_transaction

    def mark_paid!
      run_callbacks :mark_paid do
        update!(paid: true)
      end
    end

    def display_total
      currency = Spree::Config[:currency]
      Spree::Money.new(commission_transaction.amount, { currency: currency })
    end

    private
      def lock_transaction
        commission_transaction.update(locked: true)
      end

      def cannot_mark_unpaid
        errors.add(:base, Spree.t(:cannot_mark_unpaid, scope: :commission)) if !paid? && paid_changed?
      end
  end
end
