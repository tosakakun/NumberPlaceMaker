//
//  NumberPlaceMaker.swift
//  NumberPlaceMaker
//
//  Created by tosakakun on 2018/09/25.
//

import Foundation

/// 数独を作成する構造体
public struct NumberPlaceMaker {
    
    /// 穴のパターンを試す最大試行回数
    private let maxHolePatternAttemptNumber: Int
    /// 穴の数がこの数を超えたら、穴を一つずつ追加しながら問題を作る
    private let threshold: Int
    
    /// 盤面を作るための最大試行回数
    private let maxAttemptNumber: Int
    /// １つの行の数を並べるための最大試行回数
    private let maxRowAttemptNumber: Int
    /// １つのマス目の数字を決めるための最大試行回数
    private let maxSquareAttemptNumber: Int
    
    /// 解の一意性チェックの最大試行回数
    private let maxUniquenessCheckAttemptNumber: Int

    /// 数独を解く構造体
    private let solver: NumberPlaceSolver
    
    
    /// イニシャライザ
    /// - Parameters:
    ///   - maxHolePatternAttemptNumber: 穴のパターンを試す最大試行回数
    ///   - threshold: 穴の数がこの数を超えたら、穴を一つずつ追加しながら問題を作る
    ///   - maxAttemptNumber: 盤面を作るための最大試行回数
    ///   - maxRowAttemptNumber: １つの行の数を並べるための最大試行回数
    ///   - maxSquareAttemptNumber: １つのマス目の数字を決めるための最大試行回数
    ///   - maxUniquenessCheckAttemptNumber: 解の一意性チェックの最大試行回数
    public init(maxHolePatternAttemptNumber: Int = 30,
         threshold: Int = 48,
         maxAttemptNumber: Int = 10,
         maxRowAttemptNumber: Int = 100,
         maxSquareAttemptNumber: Int = 100,
         maxUniquenessCheckAttemptNumber: Int = 5) {
        
        self.maxHolePatternAttemptNumber = maxHolePatternAttemptNumber
        self.threshold = threshold
        
        self.maxAttemptNumber = maxAttemptNumber
        self.maxRowAttemptNumber = maxRowAttemptNumber
        self.maxSquareAttemptNumber = maxSquareAttemptNumber
        
        self.maxUniquenessCheckAttemptNumber = maxUniquenessCheckAttemptNumber
        
        self.solver = NumberPlaceSolver(maxUniquenessCheckAttemptNumber: maxUniquenessCheckAttemptNumber)
        
    }

    /// 数独の問題の盤面と答えの盤面を作成する
    /// - Parameter holes: 問題の盤面に作る穴の数
    /// - Returns: (問題の盤面, 答えの盤面)
    public func makeNumberPlace(holes: Int) throws -> (punchedBoard: Board, answerBoad: Board) {
        
        var provider = BoardProvider(maxAttemptNumber: maxAttemptNumber, maxRowAttemptNumber: maxRowAttemptNumber, maxSquareAttemptNumber: maxSquareAttemptNumber)
        
        // 穴の数のチェック
        guard holes < provider.numberOfSquares else {
            fatalError("穴の数が多すぎます。")
        }
        
        // 数字で埋められた盤面を準備する
        let board = try provider.provide()
        
        // 穴を開けて数独を解く
        // TODO: 穴のパターンを maxHolePatternAttemptNumber 回試すうちに一意性のある問題ができると仮定している
        // TODO: しきい値が threshold で適切かどうか要検討
        var normalHoles = holes
        var excessHoles = 0
        if holes > threshold {
            normalHoles = threshold
            excessHoles = holes - threshold
            Logger.info(message: "穴の数 \(holes) は、しきい値を超えています。(threshold: \(normalHoles), excessHoles: \(excessHoles))")
        }
        
        Logger.info(message: "***** \(normalHoles) 個の穴をランダムに開けて問題を作成 *****")
        
        // 一意の解を持つ問題が作成されるまで最大 maxHolePatternAttemptNumber 回試行する
        for i in 0..<maxHolePatternAttemptNumber {
            
            // 穴の空いた盤面を取得
            let punchedBoard = board.punchedBoard(holes: normalHoles)

            Logger.debug(message: "***** 穴を開けた数独 *****")
            Logger.debug(message: punchedBoard)

            // 数独を解き、一意性を調べる
            if solver.checkUniqueness(punchedBoard: punchedBoard, and: board) {

                Logger.info(message: "ホールパターンループ \(i) : 一意の解を持つと判断されました。")
                Logger.info(message: "***** 生成された数独（答え）*****")
                Logger.info(message: board)
                Logger.info(message: "***** 生成された数独（問題）*****")
                Logger.info(message: punchedBoard)
                
                if excessHoles > 0 {
                    // 穴の数が threshold 個より大きい問題を作るときは、穴を一つずつ増やしながら問題を作成する
                    return try increaseHoles(punchedBoard: punchedBoard, and: board, holes: holes)
                    
                } else {
                    return (punchedBoard, board)
                }
                
            } else {
                Logger.debug(message: "ホールパターンループ \(i) : 異なる解が発見されました")
            }

        }
        
        Logger.notice(message: "\(maxHolePatternAttemptNumber) 回の試行で、一意の解を持つ問題を作れませんでした。")
        throw NPError.cannotCreateNumberPlace(attemptNumber: maxHolePatternAttemptNumber)

    }

    /// 穴の数を増やしながら問題を作成する
    /// - Parameters:
    ///   - punchedBoard: 問題の盤面
    ///   - answerBoard: 解答の盤面
    ///   - holes: 問題に開けるべき穴の数
    /// - Returns: (問題の盤面, 解答の盤面)
    private func increaseHoles(punchedBoard: Board, and answerBoard: Board, holes: Int) throws -> (punchedBoard: Board, answerBoad: Board) {
        
        Logger.info(message: "***** 穴を増やしながら問題作成を継続 *****")
        
        var trialIndex = 0
        var trialBoard = punchedBoard
        
        Logger.debug(message: trialBoard)
        
        while trialIndex < punchedBoard.numberOfSquares {
            Logger.info(message: "現在の穴の数: \(trialBoard.holes)")
            // １個穴を増やす
            if let result = trialBoard.punchSingleHole(trialIndex: trialIndex) {
                
                // 一意性チェック
                if solver.checkUniqueness(punchedBoard: result.punchedBoard, and: answerBoard) {
                    
                    // 指定の穴の数になったかチェック
                    if result.punchedBoard.holes == holes {
                        
                        Logger.info(message: "問題完成 穴の数: \(holes)")
                        Logger.info(message: result.punchedBoard)
                        Logger.info(message: "答え")
                        Logger.info(message: answerBoard)
                        
                        // 問題完成
                        return (result.punchedBoard, answerBoard)
                        
                    }
                    
                    // 一意性チェックを通過した穴を採用して次のステップへ
                    trialBoard = result.punchedBoard
                    trialIndex = result.index + 1

                } else {
                    
                    // 異なる解がある場合は、穴を採用しないで次のステップへ
                    trialIndex = result.index + 1
                    
                }

            } else {
                // これ以上空白を作れない
                Logger.notice(message: "もう穴を作る場所がありません")
                throw NPError.cannotIncreaseHole
            }
            
        }
        
        // 問題作成作成失敗
        throw NPError.cannotCreateHoles

    }

}
