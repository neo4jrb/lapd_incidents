class Area
  include Neo4j::ActiveNode

  id_property :number
  property :name
end

