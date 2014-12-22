class Incident
  include Neo4j::ActiveNode

  id_property :id
  property :dr_no, type: Integer
  property :location
  property :latitute
  property :longitude

  has_one :out, :area, type: :happened_in
  has_one :out, :crime, type: :reported_crime
  has_one :out, :status, type: :has_status
end
