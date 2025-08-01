module Spree
  class CommissionTransaction < Spree::Base
    belongs_to :affiliate, class_name: 'Spree::Affiliate', required: true
    belongs_to :commission, class_name: 'Spree::Commission', required: true, counter_cache: :transactions_count
    belongs_to :commissionable, polymorphic: true, required: true
    belongs_to :payout, class_name: 'Spree::Payout', optional: true

    validate :cannot_change_commisson, :check_not_locked

    before_validation :assign_commission, :evaluate_amount, on: :create

    self.whitelisted_ransackable_attributes =  %w[amount created_at commission_id]

    def display_total
      currency = Spree::Config[:currency]
      Spree::Money.new(amount, { currency: currency })
    end

    private
      def assign_commission
        self.commission = Spree::Commission.create!(affiliate_id: affiliate.id)
      end

      def cannot_change_commisson
        errors.add(:base, Spree.t(:cannot_change_commisson, scope: :commission_transaction)) if persisted? && commission_id.changed?
      end

      def evaluate_amount
        self.amount = Spree::TransactionService.new(self).calculate_commission_amount
        return true
      end

      def check_not_locked
        errors.add(:base, Spree.t(:locked_transaction, :commission_transaction)) if locked?
      end
  end
end
