# frozen_string_literal: true

module Api
  module V1
    module Concerns
      module VersionableActions
        extend ActiveSupport::Concern

        def versions
          resource = find_versionable_resource
          render_paginated(resource.versions.order(created_at: :desc), serializer: Api::V1::VersionSerializer)
        end

        def revert_version
          resource = find_versionable_resource
          version = resource.versions.find(params[:version_id])
          reified = version.reify

          unless reified
            render_error(
              code: 'unprocessable_entity',
              message: 'Cannot reify this version (initial creation version cannot be reified).',
              status: :unprocessable_entity
            )
            return
          end

          reified.pending = false if reified.respond_to?(:pending)
          reified.rendering = false if reified.respond_to?(:rendering)
          reified.save!

          render_data(versionable_serializer.render(reified))
        end

        def merge_version
          resource = find_versionable_resource
          version = resource.versions.find(params[:version_id])

          resource.update(pending: true) if resource.respond_to?(:pending)

          enqueue_operation!(
            resource: resource,
            operation_type: 'merge_version',
            job_class: merge_job_class,
            metadata: { 'version_id' => version.id },
            resource_serializer: versionable_serializer
          )
        end

        private

        def find_versionable_resource
          raise NotImplementedError
        end

        def versionable_serializer
          raise NotImplementedError
        end

        def merge_job_class
          raise NotImplementedError
        end
      end
    end
  end
end
