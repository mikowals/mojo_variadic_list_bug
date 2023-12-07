import time

from algorithm.sort import partition
from utils.list import Dim
from memory.memory import memcpy


@value
@register_passable("trivial")
struct Slice(CollectionElement, Stringable):
    var start: Int
    var end: Int

    fn __str__(self) -> String:
        return "Slice(" + String(self.start) + ", " + String(self.end) + ")"


@value
@register_passable("trivial")
struct Mapping(CollectionElement, Stringable):
    var destination: Int
    var start: Int
    var end: Int

    fn __init__(destination: Int, start: Int, range: Int) -> Self:
        return Self {destination: destination, start: start, end: start + range}

    fn read_mapping(self, seed: Slice) -> VariadicList[Slice]:
        # removing this error check fixes the bug
        if seed.start < self.start or seed.start >= self.end:
            # The print message is not reached during the bug case but
            # making print message shorter or without variables fixes the bug
            print(
                "read mapping slice: Value out of range. slice: "
                + seed.__str__()
                + " start: "
                + self.start
                + " end: "
                + self.end
            )
        let result = VariadicList[Slice](Slice(83, 95))
        # The bug persists without this print but it is useful to see that result is correct here.
        print("result in read_mapping: ", len(result), result[0])
        return result

    fn __str__(self) -> String:
        return (
            "Mapping: "
            + String(self.destination)
            + " - "
            + String(self.start)
            + " - "
            + String(self.end)
        )


struct MappingList:
    var mappings: DynamicVector[Mapping]

    fn __init__(inout self):
        self.mappings = DynamicVector[Mapping]()
        self.mappings.push_back(Mapping(52, 50, 48))

    fn add(inout self, mapping: Mapping) raises:
        self.mappings.push_back(mapping)

    fn map_result(inout self, seed: Slice) raises -> VariadicList[Slice]:
        let val = seed.start

        # removing this if fixes the bug
        if val < self[0].start:
            print("unreachable if in map result")
            return VariadicList[Slice](Slice(0, 0))
            # return Mapping(0, 0, self[0].start).read_mapping(seed)

        # removing this print fixes the bug
        print("mid: ", 0, self[0])
        return self[0].read_mapping(seed)

    fn translate(inout self, inout seeds: DynamicVector[Slice]) raises:
        let current = self.map_result(seeds[0])
        # removing this print or the len(current) in the print fixes the bug
        print("map result length: ", len(current))
        # changing this for to just print the current[0] fixes the bug
        for j in range(len(current)):
            print("result in translate: ", current[j])

    fn __getitem__(self, index: Int) raises -> Mapping:
        return self.mappings[index]


fn main() raises:
    var mappings = MappingList()
    # removing this add fixes the bug.
    mappings.add(Mapping(50, 98, 2))
    # mappings.translate calls mappings[0].map_result.
    # Calling mappings[0].map_result directly fixes the bug.
    var seeds = DynamicVector[Slice]()
    seeds.push_back(Slice(79, 93))
    mappings.translate(seeds)
