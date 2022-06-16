import XCTest
@testable import NumberPlaceMaker

final class NumberPlaceMakerTests: XCTestCase {
    
    func testBoardHoleNumber() throws {
        
        var board = Board()
        XCTAssertEqual(board.holes, 81)
        
        board.squares[0] = 1
        XCTAssertEqual(board.holes, 80)
        
        board.squares[34] = 5
        XCTAssertEqual(board.holes, 79)
        
    }
    
    func testBoardClear() throws {
        
        var boad = Board()
        for i in 0..<boad.numberOfSquares {
            boad.squares[i] = i
        }
        
        boad.clear()
        
        let initialBoard = Board()
        
        XCTAssertEqual(boad, initialBoard)

    }
    
    func testBoardClearRow() throws {
        
        var boad = Board()
        
        for i in 0..<boad.numberOfSquares {
            boad.squares[i] = 9
        }
        
        for i in 9..<18 {
            boad.squares[i] = 2
        }
        
        boad.clearRow(y: 1)
        
        for i in 9..<18 {
            XCTAssertEqual(boad.squares[i], 0, "index \(i)")
        }
        
    }
    
    func testBoardBlock() throws {
        
        var boad = Board()
        
        for i in 0..<boad.numberOfSquares {
            boad.squares[i] = i + 1
        }
        
        let block00 = boad.block(at: CGPoint(x: 0, y: 0))
        XCTAssertEqual(block00, [1,2,3,10,11,12,19,20,21])
        
        let block10 = boad.block(at: CGPoint(x: 1, y: 0))
        XCTAssertEqual(block10, [4,5,6,13,14,15,22,23,24])
        
        let block20 = boad.block(at: CGPoint(x: 2, y: 0))
        XCTAssertEqual(block20, [7,8,9,16,17,18,25,26,27])
        
        let block01 = boad.block(at: CGPoint(x: 0, y: 1))
        XCTAssertEqual(block01, [28,29,30,37,38,39,46,47,48])
        
        let block11 = boad.block(at: CGPoint(x: 1, y: 1))
        XCTAssertEqual(block11, [31,32,33,40,41,42,49,50,51])
        
        let block21 = boad.block(at: CGPoint(x: 2, y: 1))
        XCTAssertEqual(block21, [34,35,36,43,44,45,52,53,54])
        
        let block02 = boad.block(at: CGPoint(x: 0, y: 2))
        XCTAssertEqual(block02, [55,56,57,64,65,66,73,74,75])
        
        let block12 = boad.block(at: CGPoint(x: 1, y: 2))
        XCTAssertEqual(block12, [58,59,60,67,68,69,76,77,78])
        
        let block22 = boad.block(at: CGPoint(x: 2, y: 2))
        XCTAssertEqual(block22, [61,62,63,70,71,72,79,80,81])
        
    }
    
    func testBoardRowNumbers() throws {
        
        var boad = Board()
        
        for i in 0..<boad.numberOfSquares {
            boad.squares[i] = i + 1
        }
        
        for i in 0..<9 {
            let row = boad.rowNumbers(at: i)
            
            var ans = [Int]()
            for j in 0..<9 {
                ans.append(i * 9 + (j + 1))
            }
            
            XCTAssertEqual(row, ans)
        }
        
    }
    
    func testBoardColumnNumbers() throws {
        
        var boad = Board()
        
        for i in 0..<boad.numberOfSquares {
            boad.squares[i] = i + 1
        }
        
        for i in 0..<9 {
            let column = boad.columnNumbers(at: i)
            
            var ans = [Int]()
            for j in 0..<9 {
                ans.append((i + 1) + j * 9 )
            }
            
            XCTAssertEqual(column, ans)
        }
        
    }
    
    func testBoardPunchedBoard() throws {
        
        var boad = Board()
        
        for i in 0..<boad.numberOfSquares {
            boad.squares[i] = i + 1
        }
        
        let punchedBoard = boad.punchedBoard(holes: 10)
        XCTAssertEqual(punchedBoard.holes, 10)

    }
    
    func testBoardPunchSingleHole() throws {
        
        var boad = Board()
        
        for i in 0..<boad.numberOfSquares {
            boad.squares[i] = i + 1
        }
        
        let result = boad.punchSingleHole(trialIndex: 3)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.index, 3)
        XCTAssertEqual(result?.punchedBoard.holes, 1)
        
        boad.squares[80] = 0
        
        let badResult = boad.punchSingleHole(trialIndex: 80)
        
        XCTAssertNil(badResult)
        
    }
    
    func testBoardSquarePoint() throws {
        
        let board = Board()
        
        let pointOrign = board.squarePoint(from: 0)
        XCTAssertEqual(pointOrign, CGPoint(x: 0, y: 0))
        
        let pointEnd = board.squarePoint(from: 80)
        XCTAssertEqual(pointEnd, CGPoint(x: 8, y: 8))

    }
    
    func testBoardSquareIndex() throws {
        
        let board = Board()
        
        let indexOrign = board.squareIndex(from: CGPoint(x: 0, y: 0))
        XCTAssertEqual(indexOrign, 0)
        
        let indexEnd = board.squareIndex(from: CGPoint(x: 8, y: 8))
        XCTAssertEqual(indexEnd, 80)
        
    }
    
}
