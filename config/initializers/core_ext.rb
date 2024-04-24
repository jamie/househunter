class Hash
  def diff(h2)
    dup.delete_if { |k, v| h2[k] == v }.merge(h2.dup.delete_if { |k, v| has_key?(k) })
  end
end
