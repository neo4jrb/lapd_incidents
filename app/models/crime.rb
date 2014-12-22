class Crime
  include Neo4j::ActiveNode

  id_property :code
  property :description
end


