
# Indexes

Osmium offers serveral different indexes and none of them is suitable for
every use case. It's you who has to choose the suitable index type. See
[Osmium Concepts Manual](../osmium-concepts-manual/#indexes) for a list of
the available indexes.

If you want to choose the index type on runtime, you can use
`osmium::index::MapFactory`. The following source code listing shows its
usage. `location_index_type` is a variable you either set based on the
preferences of the user of your program or based on your own estimations (e.g.
file size).

~~~{.cpp}
using index_type = osmium::index::map::Map<osmium::unsigned_object_id_type, osmium::Location>;
using location_handler_type = osmium::handler::NodeLocationsForWays<index_type>;
std::string location_index_type = "sparse_mem_array";
const auto& map_factory = osmium::index::MapFactory<osmium::unsigned_object_id_type, osmium::Location>::instance();
auto location_index = map_factory.create_map(location_index_type);
location_handler_type location_handler(*location_index);
~~~

