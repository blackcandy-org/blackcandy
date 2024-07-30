# frozen_string_literal: true

module ComponentHelper
  def merge_attributes(*hashes)
    hashes.compact.reduce({}, :merge)
  end
end
