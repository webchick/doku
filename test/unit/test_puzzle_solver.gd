extends GutTest

# Zero solutions: proven unsolvable by exhaustive search (see the region
# uniqueness discussion in test_validation.gd's shared REGION_MAP).
const UNSOLVABLE_REGION_MAP = [
	[0, 0, 1, 1],
	[0, 2, 2, 1],
	[3, 2, 2, 1],
	[3, 3, 3, 1]
]

# Exactly one solution: of the two 4x4 permutations that satisfy the
# adjacency rule on their own -- (1,3,0,2) and (2,0,3,1) -- this region
# layout puts (2,0,3,1)'s cells (0,2) and (1,0) in the same region, so
# only (1,3,0,2) survives.
const UNIQUE_REGION_MAP = [
	[0, 0, 0, 1],
	[0, 1, 1, 1],
	[2, 2, 3, 3],
	[2, 2, 3, 3]
]

func test_counts_zero_for_an_unsolvable_region_map():
	var puzzle = PuzzleBoard.new(4, 4, UNSOLVABLE_REGION_MAP)
	var solver = PuzzleSolver.new()

	assert_eq(solver.count_solutions(puzzle), 0)

func test_counts_exactly_one_for_a_unique_region_map():
	var puzzle = PuzzleBoard.new(4, 4, UNIQUE_REGION_MAP)
	var solver = PuzzleSolver.new()

	assert_eq(solver.count_solutions(puzzle), 1)

func test_stops_at_limit_for_an_ambiguous_region_map():
	# One region per row leaves column choice and adjacency as the only
	# real constraints, and exactly two permutations satisfy those on a
	# 4x4 board -- so this region map is ambiguous.
	var row_regions = [
		[0, 0, 0, 0],
		[1, 1, 1, 1],
		[2, 2, 2, 2],
		[3, 3, 3, 3]
	]
	var puzzle = PuzzleBoard.new(4, 4, row_regions)
	var solver = PuzzleSolver.new()

	assert_eq(solver.count_solutions(puzzle, 2), 2)

func test_stops_early_when_limit_is_reached():
	var row_regions = [
		[0, 0, 0, 0],
		[1, 1, 1, 1],
		[2, 2, 2, 2],
		[3, 3, 3, 3]
	]
	var puzzle = PuzzleBoard.new(4, 4, row_regions)
	var solver = PuzzleSolver.new()

	assert_eq(solver.count_solutions(puzzle, 1), 1)

func test_generated_puzzles_always_have_at_least_one_solution():
	var generator = PuzzleGenerator.new()
	var solver = PuzzleSolver.new()
	var solution = generator.generate_solution(4)
	var region_map = generator.build_regions(solution)
	var puzzle = PuzzleBoard.new(4, 4, region_map)

	assert_true(solver.count_solutions(puzzle, 5) >= 1)
