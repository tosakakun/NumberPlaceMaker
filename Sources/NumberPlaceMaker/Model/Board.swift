//
//  Board.swift
//  NumberPlaceMaker
//
//  Created by tosakakun on 2018/09/20.
//

import Foundation

/// 数独の盤面を表す構造体
public struct Board {
    
    /// 列数
    let numberOfColumns: Int = 9
    /// 行数
    let numberOfRows: Int = 9
    /// マス目の数
    let numberOfSquares: Int = 9 * 9
    /// マス目
    var squares: [Int]
    
    /// １つのブロックに含まれるの列数
    let blockNumberOfColumns: Int = 3
    /// １つのブロックに含まれる行数
    let blockNumberOfRows: Int = 3
    
    /// 空白の数
    var holes: Int {
        get {
            var count = 0
            for square in squares {
                if square == 0 {
                    count += 1
                }
            }
            return count
        }
    }
    
    /// イニシャライザ
    public init() {
        
        self.squares = Array(repeating: 0, count: self.numberOfSquares)
        
    }

    // MARK: - 盤面操作メソッド
    
    /// マス目をすべてクリア(0に)する
    public mutating func clear() {
        for index in 0..<self.numberOfSquares {
            self.squares[index] = 0
        }
    }
    
    
    /// y行目をクリア(0)にする
    ///
    /// - Parameter y: クリアする行番後
    public mutating func clearRow(y: Int) {
        
        for x in 0..<numberOfColumns {
            let index = squareIndex(from: CGPoint(x: x, y: y))
            squares[index] = 0
        }
        
    }
    

    // MARK: - 盤面の一部を取得するメソッド
    
    /// ブロックを取り出す
    ///
    /// - Parameter point: ブロックの行列番号(x: 列、y: 行）
    /// - Returns: ブロックに含まれている数字の配列
    public func block(at point: CGPoint) -> [Int] {
        
        guard Int(point.x) < self.blockNumberOfColumns && Int(point.y) < self.blockNumberOfRows else {
            fatalError("エリアの行列番号が大きすぎます。")
        }
        
        var block = [Int]()
        // 指定されたブロックの始まりの列番号
        let startColumnNo = Int(point.x) * self.blockNumberOfColumns
        // 指定されたブロックの終わりを表す列番号（含まない）
        let endColumNo = startColumnNo + self.blockNumberOfColumns
        // 指定されたブロックの始まりの行番号
        let startRowNo = Int(point.y) * self.blockNumberOfRows
        // 指定されたブロックの終わりを表す列番号（含まない）
        let endRowNo = startRowNo + self.blockNumberOfRows
        
        for row in startRowNo..<endRowNo {
            
            for column in startColumnNo..<endColumNo {
                
                let index = squareIndex(from: CGPoint(x: column, y: row))
                
                block.append(self.squares[index])
                
            }
            
        }

        return block
        
    }
    
    
    /// y行目を取得する
    ///
    /// - Parameter y: 行番号
    /// - Returns: y行目のに含まれている数字の配列
    public func rowNumbers(at y: Int) -> [Int] {
        
        var elements = [Int]()
        
        for x in 0..<self.numberOfColumns {
            let index = squareIndex(from: CGPoint(x: x, y: y))
            elements.append(self.squares[index])
        }
        
        return elements
    }
    
    
    /// x列目を取得する
    ///
    /// - Parameter x: 列番号
    /// - Returns: x列目に含まれている数字の配列
    public func columnNumbers(at x: Int) -> [Int] {
        
        var elements = [Int]()
        
        for y in 0..<self.numberOfRows {
            let index = squareIndex(from: CGPoint(x: x, y: y))
            elements.append(self.squares[index])
        }
        
        return elements
    }
    
    
    // MARK: - 穴の空いた盤面を取得するメソッド
    
    /// 与えられた数の穴をランダムに開けた盤面を返す
    ///
    /// - Parameter holes: 穴を開ける個数
    /// - Returns: 穴が空いた盤面
    public func punchedBoard(holes: Int) -> Board {
        
        guard holes < self.numberOfSquares else {
            fatalError("穴の数が大きすぎます。")
        }
        
        // 盤面をコピー
        var punchedSquares = self.squares
        
        // 0〜80の配列を作成（配列の添字）
        var indices = [Int]()
        for index in 0..<self.numberOfSquares {
            indices.append(index)
        }
        
        // 適当な位置に穴を開ける(0にする）
        for _ in 0..<holes {
            
            let randomIndex = Int.random(in: 0..<indices.count)
            
            let index = indices.remove(at: randomIndex)
            
            punchedSquares[index] = 0
            
        }
        
        // 盤面を作成して返す
        var punchedBoard = Board()
        punchedBoard.squares = punchedSquares
        
        return punchedBoard
        
    }
    
    
    /// 一つ空白を追加する
    ///
    /// - Parameter trialIndex: 空白を探し始める添字
    /// - Returns: index: 空白を追加した要素の添字 / punchedBoard: 空白を追加した盤面
    public func punchSingleHole(trialIndex: Int) -> (index: Int, punchedBoard: Board)? {
        
        // 盤面をコピー
        var punchedSquares = self.squares
        // 空白でないマスを探す
        for index in trialIndex..<punchedSquares.count {
            
            if punchedSquares[index] != 0 {
                
                Logger.info(message: "index \(index) のマスに穴を開けます")

                // 穴を開ける
                punchedSquares[index] = 0
                
                // 盤面を作成して返す
                var punchedBoard = Board()
                punchedBoard.squares = punchedSquares
                
                return (index, punchedBoard)
                
            }

        }

        // もう穴を開けるところがありません
        Logger.debug(message: "もう穴を開けるところがありません")
        return nil
        
    }
    
    // MARK: - 添字の変換メソッド
    
    /// マス目の配列の添字を行列番号に変換する
    ///
    /// - Parameter index: マス目の配列の添字
    /// - Returns: マス目の行列番号
    public func squarePoint(from index: Int) -> CGPoint {
        
        guard index < self.numberOfSquares else {
            fatalError("マス目の配列の添字が大きすぎます。")
        }
        
        return CGPoint(x: index % numberOfColumns, y: index / numberOfColumns)
        
    }
    
    
    /// マス目の行列番号を配列の添字に変換する
    ///
    /// - Parameter point: マス目の行列番号(x: 列、y: 行）
    /// - Returns: マス目の配列の添字
    public func squareIndex(from point: CGPoint) -> Int {
        
        guard Int(point.x) < self.numberOfColumns && Int(point.y) < self.numberOfRows else {
            fatalError("マス目の行列番号が大きすぎます。")
        }
        
        return Int(point.y) * numberOfColumns + Int(point.x)
        
    }
    
}

// MARK: - CustomDebugStringConvertible
extension Board: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        
        var debugString = "\n"
        
        for row in 0..<self.numberOfRows {
            
            for column in 0..<self.numberOfColumns {
            
                let index = squareIndex(from: CGPoint(x: column, y: row))
                
                debugString += self.squares[index] == 0 ? "[ ]" : "[\(self.squares[index])]"
                
            }
            
            debugString += "\n"
            
        }
        
        return debugString
        
    }
    
}

// MARK: - Equatable
extension Board: Equatable {
    
    public static func == (lhs: Board, rhs: Board) -> Bool {
        lhs.squares == rhs.squares
    }

}
