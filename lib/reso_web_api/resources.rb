module ResoWebApi
  # Grants access to a service's resources in a convenient manner
  module Resources
    STANDARD_RESOURCES = {
      properties: 'Property',
      members:    'Member',
      offices:    'Office',
      media:      'Media'
    }

    STANDARD_RESOURCES.each do |method, resource|
      define_method(method) do
        resources[resource]
      end
    end

    def resources
      service
    end
  end
end
