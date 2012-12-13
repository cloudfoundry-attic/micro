module VCAP

  module Micro

    module Api

      module Engine

        # Media type superclass.
        #
        # Subclass this class to create specific media types.
        class MediaType
          include JsonSerializable

          def initialize(fields={})
            @_links = {}
          end

          # Add a link.
          def link(rel, href)
            link_def = self.class::Links[rel]

            unless link_def
              raise "#{self.class} does not have link rel '#{rel}' defined"
            end

            @_links[rel] = {
              :method => link_def[0],
              :href => href,
              :type => link_def[1]::MediaType
            }

            self
          end

          attr :_links

          # Keep track of subclasses.
          @subclasses = []

          def self.inherited(child)
            subclasses << child

            # Create this on any subclasses so JSON.parse will find them.
            child.instance_eval {

              def json_create(o)
                # Convert keys to symbols.
                sym_data = Hash[o['data'].map { |k,v| [k.to_sym, v] }]

                new sym_data
              end

            }
          end

          class << self;
            attr_reader :subclasses
          end

          # Look up a subclass by its content type.
          def self.from_content_type(content_type)
            subclasses.find { |c| c::MediaType == content_type }
          end

          # Respond to each so every subclass can act as a Rack body.
          def each
            yield to_json
          end

          def self.graph
            GraphViz::new(:G, :type => :digraph) do |g|
              subclasses.inject({}) { |types,sc| add_to_graph(g, sc, types) }
            end
          end

          def self.add_to_graph(graph, klass, types={})
            return types  if types[klass.name]

            types[klass.name] = graph.add_nodes(klass.name.split('::').last)

            klass::Links.each_pair do |rel,methodtype|
              method, type = methodtype
              add_to_graph(graph, type, types)
              graph.add_edges(
                types[klass.name], types[type.name])[:label] = rel
            end

            types
          end

        end

      end

    end

  end

end
