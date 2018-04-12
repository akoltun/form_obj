module ResultObj
  def failure?
    @errors.present?
  end

  def success?
    !failure?
  end
end
