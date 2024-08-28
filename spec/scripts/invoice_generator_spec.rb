# frozen_string_literal: true

require 'spec_helper'
require_relative '../../app/scripts/invoice_generator'

RSpec.describe InvoiceGenerator, :vcr do
  it 'creates invoices' do
    expect { described_class.call }.not_to raise_error
  end
end
