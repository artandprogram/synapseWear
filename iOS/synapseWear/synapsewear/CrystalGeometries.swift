//
//  CrystalGeometries.swift
//  synapsewear
//
//  Copyright © 2017 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

import UIKit
import SceneKit

class CrystalGeometries: NSObject, CommonFunctionProtocol {

    let colorSR: CGFloat = 91
    let colorSG: CGFloat = 18
    let colorSB: CGFloat = 137
    let colorER: CGFloat = 230
    let colorEG: CGFloat = 19
    let colorEB: CGFloat = 100

    func makeCO2CrystalGeometry(_ size: Float) -> SCNGeometry {

        let baseS: Float = size * 0.8
        let vertices: [SCNVector3] = [
            SCNVector3(0,            size / 2.0,  0),
            SCNVector3(-baseS / 2.0, -size / 2.0, baseS / 2.0 * Float(tan(Double.pi / 180.0 * 30.0))),
            SCNVector3(baseS / 2.0,  -size / 2.0, baseS / 2.0 * Float(tan(Double.pi / 180.0 * 30.0))),

            SCNVector3(0,            size / 2.0,  0),
            SCNVector3(0,            -size / 2.0, -baseS / 2.0 / Float(cos(Double.pi / 180.0 * 30.0))),
            SCNVector3(-baseS / 2.0, -size / 2.0, baseS / 2.0 * Float(tan(Double.pi / 180.0 * 30.0))),

            SCNVector3(0,            size / 2.0,  0),
            SCNVector3(0,            -size / 2.0, -baseS / 2.0 / Float(cos(Double.pi / 180.0 * 30.0))),
            SCNVector3(baseS / 2.0,  -size / 2.0, baseS / 2.0 * Float(tan(Double.pi / 180.0 * 30.0))),

            SCNVector3(0,            -size / 2.0, -baseS / 2.0 / Float(cos(Double.pi / 180.0 * 30.0))),
            SCNVector3(-baseS / 2.0, -size / 2.0, baseS / 2.0 * Float(tan(Double.pi / 180.0 * 30.0))),
            SCNVector3(baseS / 2.0,  -size / 2.0, baseS / 2.0 * Float(tan(Double.pi / 180.0 * 30.0))),
            ]
        let normals: [SCNVector3] = [
            SCNVector3(0, 0, 1),
            SCNVector3(0, 0, 1),
            SCNVector3(0, 0, 1),

            SCNVector3(-1, 0, 0),
            SCNVector3(-1, 0, 0),
            SCNVector3(-1, 0, 0),

            SCNVector3(1, 0, 0),
            SCNVector3(1, 0, 0),
            SCNVector3(1, 0, 0),

            SCNVector3(0, -1, 0),
            SCNVector3(0, -1, 0),
            SCNVector3(0, -1, 0),
            ]
        let indices: [Int32] = [
            0, 1, 2,
            3, 4, 5,
            6, 8, 7,
            9, 11, 10,
            ]
        let texcoords: [float2] = [
            float2(1, 1),
            float2(1, 1),
            float2(0, 0),
            
            float2(1, 1),
            float2(1, 1),
            float2(0, 0),
            
            float2(1, 1),
            float2(1, 1),
            float2(0, 0),
            
            float2(1, 1),
            float2(1, 1),
            float2(0, 0),
            ]
        let verticesSource: SCNGeometrySource = SCNGeometrySource(vertices: vertices)
        let normalsSource: SCNGeometrySource = SCNGeometrySource(normals: normals)
        //let verticesSource = SCNGeometrySource(vertices: vertices, count: vertices.count)
        //let normalsSource = SCNGeometrySource(normals: normals, count: normals.count)
        let texcoordSource: SCNGeometrySource = SCNGeometrySource(textureCoordinates: texcoords)
        let faceSource: SCNGeometryElement = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        return SCNGeometry(sources: [verticesSource, normalsSource, texcoordSource], elements: [faceSource])
    }

    func makeHumidityCrystalGeometry(_ size: Float) -> SCNGeometry {

        let baseS: Float = size / 2
        let vertices: [SCNVector3] = [
            SCNVector3(0,            baseS,  0),
            SCNVector3(-baseS / 2.0, 0,      -baseS / 2.0),
            SCNVector3(baseS / 2.0,  0,      -baseS / 2.0),

            SCNVector3(-baseS / 2.0, -baseS, -baseS / 2.0),
            SCNVector3(-baseS / 2.0, 0,      -baseS / 2.0),
            SCNVector3(baseS / 2.0,  0,      -baseS / 2.0),

            SCNVector3(baseS / 2.0,  0,      -baseS / 2.0),
            SCNVector3(baseS / 2.0,  -baseS, -baseS / 2.0),
            SCNVector3(-baseS / 2.0, -baseS, -baseS / 2.0),

            SCNVector3(0,            baseS,  0),
            SCNVector3(-baseS / 2.0, 0,      -baseS / 2.0),
            SCNVector3(0,            0,      baseS / 2.0),

            SCNVector3(0,            baseS,  0),
            SCNVector3(baseS / 2.0,  0,      -baseS / 2.0),
            SCNVector3(0,            0,      baseS / 2.0),

            SCNVector3(-baseS / 2.0, -baseS, -baseS / 2.0),
            SCNVector3(-baseS / 2.0, 0,      -baseS / 2.0),
            SCNVector3(0,            0,      baseS / 2.0),

            SCNVector3(0,            0,      baseS / 2.0),
            SCNVector3(0,            -baseS, baseS / 2.0),
            SCNVector3(-baseS / 2.0, -baseS, -baseS / 2.0),
            
            SCNVector3(baseS / 2.0,  -baseS, -baseS / 2.0),
            SCNVector3(baseS / 2.0,  0,      -baseS / 2.0),
            SCNVector3(0,            0,      baseS / 2.0),
            
            SCNVector3(0,            0,      baseS / 2.0),
            SCNVector3(0,            -baseS, baseS / 2.0),
            SCNVector3(baseS / 2.0,  -baseS, -baseS / 2.0),

            SCNVector3(0,            -baseS, baseS / 2.0),
            SCNVector3(-baseS / 2.0, -baseS, -baseS / 2.0),
            SCNVector3(baseS / 2.0,  -baseS, -baseS / 2.0),
            ]
        let normals: [SCNVector3] = [
            SCNVector3(0, 0, -1),
            SCNVector3(0, 0, -1),
            SCNVector3(0, 0, -1),

            SCNVector3(0, 0, -1),
            SCNVector3(0, 0, -1),
            SCNVector3(0, 0, -1),

            SCNVector3(0, 0, -1),
            SCNVector3(0, 0, -1),
            SCNVector3(0, 0, -1),

            SCNVector3(-1, 0, 1),
            SCNVector3(-1, 0, 1),
            SCNVector3(-1, 0, 1),

            SCNVector3(1, 0, 1),
            SCNVector3(1, 0, 1),
            SCNVector3(1, 0, 1),

            SCNVector3(-1, 0, 1),
            SCNVector3(-1, 0, 1),
            SCNVector3(-1, 0, 1),

            SCNVector3(-1, 0, 1),
            SCNVector3(-1, 0, 1),
            SCNVector3(-1, 0, 1),
            
            SCNVector3(1, 0, 1),
            SCNVector3(1, 0, 1),
            SCNVector3(1, 0, 1),
            
            SCNVector3(1, 0, 1),
            SCNVector3(1, 0, 1),
            SCNVector3(1, 0, 1),

            SCNVector3(0, -1, 0),
            SCNVector3(0, -1, 0),
            SCNVector3(0, -1, 0),
            ]
        let indices: [Int32] = [
            2, 1, 0,
            3, 4, 5,
            6, 7, 8,
            9, 10, 11,
            14, 13, 12,
            17, 16, 15,
            20, 19, 18,
            21, 22, 23,
            24, 25, 26,
            27, 28, 29,
            ]
        let texcoords: [float2] = [
            float2(1, 1),
            float2(1, 1),
            float2(0, 0),
            
            float2(1, 1),
            float2(1, 1),
            float2(0, 0),
            
            float2(0, 0),
            float2(0, 0),
            float2(1, 1),

            float2(1, 1),
            float2(1, 1),
            float2(0, 0),

            float2(1, 1),
            float2(1, 1),
            float2(0, 0),
            
            float2(1, 1),
            float2(1, 1),
            float2(0, 0),
            
            float2(0, 0),
            float2(0, 0),
            float2(1, 1),
            
            float2(1, 1),
            float2(1, 1),
            float2(0, 0),
            
            float2(0, 0),
            float2(0, 0),
            float2(1, 1),

            float2(0, 0),
            float2(1, 1),
            float2(1, 1),
            ]
        let verticesSource: SCNGeometrySource = SCNGeometrySource(vertices: vertices)
        let normalsSource: SCNGeometrySource = SCNGeometrySource(normals: normals)
        //let verticesSource = SCNGeometrySource(vertices: vertices, count: vertices.count)
        //let normalsSource = SCNGeometrySource(normals: normals, count: normals.count)
        let texcoordSource: SCNGeometrySource = SCNGeometrySource(textureCoordinates: texcoords)
        let faceSource: SCNGeometryElement = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        return SCNGeometry(sources: [verticesSource, normalsSource, texcoordSource], elements: [faceSource])
    }

    func makeIlluminationCrystalGeometry(_ size: Float) -> SCNGeometry {

        let baseS: Float = size * 0.5
        let baseS2: Float = size * 0.08
        let vertices: [SCNVector3] = [
            SCNVector3(0,             baseS,  -baseS2 / 2.0),
            SCNVector3(-baseS2 / 2.0, 0,      -baseS2 / 2.0),
            SCNVector3(baseS2 / 2.0,  0,      -baseS2 / 2.0),

            SCNVector3(0,             -baseS, -baseS2 / 2.0),
            SCNVector3(-baseS2 / 2.0, 0,      -baseS2 / 2.0),
            SCNVector3(baseS2 / 2.0,  0,      -baseS2 / 2.0),

            SCNVector3(0,             baseS,  -baseS2 / 2.0),
            SCNVector3(-baseS2 / 2.0, 0,      -baseS2 / 2.0),
            SCNVector3(0,             0,      baseS2 / 2.0),

            SCNVector3(0,             -baseS, -baseS2 / 2.0),
            SCNVector3(-baseS2 / 2.0, 0,      -baseS2 / 2.0),
            SCNVector3(0,             0,      baseS2 / 2.0),

            SCNVector3(0,             baseS,  -baseS2 / 2.0),
            SCNVector3(baseS2 / 2.0,  0,      -baseS2 / 2.0),
            SCNVector3(0,             0,      baseS2 / 2.0),

            SCNVector3(0,             -baseS, -baseS2 / 2.0),
            SCNVector3(baseS2 / 2.0,  0,      -baseS2 / 2.0),
            SCNVector3(0,             0,      baseS2 / 2.0),
            ]
        let normals: [SCNVector3] = [
            SCNVector3(0, 0, -1),
            SCNVector3(0, 0, -1),
            SCNVector3(0, 0, -1),
            
            SCNVector3(0, 0, -1),
            SCNVector3(0, 0, -1),
            SCNVector3(0, 0, -1),

            SCNVector3(-1, 0, 1),
            SCNVector3(-1, 0, 1),
            SCNVector3(-1, 0, 1),
            
            SCNVector3(-1, 0, 1),
            SCNVector3(-1, 0, 1),
            SCNVector3(-1, 0, 1),

            SCNVector3(1, 0, 1),
            SCNVector3(1, 0, 1),
            SCNVector3(1, 0, 1),
            
            SCNVector3(1, 0, 1),
            SCNVector3(1, 0, 1),
            SCNVector3(1, 0, 1),
            ]
        let indices: [Int32] = [
            0, 2, 1,
            3, 4, 5,
            6, 7, 8,
            11, 10, 9,
            14, 13, 12,
            15, 16, 17,
            ]
        let texcoords: [float2] = [
            float2(1, 1),
            float2(1, 1),
            float2(0, 0),
            
            float2(1, 1),
            float2(1, 1),
            float2(0, 0),
            
            float2(1, 1),
            float2(1, 1),
            float2(0, 0),
            
            float2(1, 1),
            float2(1, 1),
            float2(0, 0),

            float2(1, 1),
            float2(1, 1),
            float2(0, 0),
            
            float2(1, 1),
            float2(1, 1),
            float2(0, 0),
            ]
        let verticesSource: SCNGeometrySource = SCNGeometrySource(vertices: vertices)
        let normalsSource: SCNGeometrySource = SCNGeometrySource(normals: normals)
        //let verticesSource = SCNGeometrySource(vertices: vertices, count: vertices.count)
        //let normalsSource = SCNGeometrySource(normals: normals, count: normals.count)
        let texcoordSource: SCNGeometrySource = SCNGeometrySource(textureCoordinates: texcoords)
        let faceSource: SCNGeometryElement = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        return SCNGeometry(sources: [verticesSource, normalsSource, texcoordSource], elements: [faceSource])
    }

    func makePressureCrystalGeometry(_ size: Float) -> SCNGeometry {

        let baseS: Float = size * 0.5
        let baseS2: Float = baseS * 0.4
        let vertices: [SCNVector3] = [
            SCNVector3(0,             baseS,  0),
            SCNVector3(-baseS2 / 2.0, 0,      baseS2 / 2.0 * Float(tan(Double.pi / 180.0 * 30.0))),
            SCNVector3(baseS2 / 2.0,  0,      baseS2 / 2.0 * Float(tan(Double.pi / 180.0 * 30.0))),

            SCNVector3(0,             baseS,  0),
            SCNVector3(0,             0,      -baseS2 / 2.0 / Float(cos(Double.pi / 180.0 * 30.0))),
            SCNVector3(-baseS2 / 2.0, 0,      baseS2 / 2.0 * Float(tan(Double.pi / 180.0 * 30.0))),

            SCNVector3(0,             baseS,  0),
            SCNVector3(0,             0,      -baseS2 / 2.0 / Float(cos(Double.pi / 180.0 * 30.0))),
            SCNVector3(baseS2 / 2.0,  0,      baseS2 / 2.0 * Float(tan(Double.pi / 180.0 * 30.0))),

            SCNVector3(0,             -baseS, 0),
            SCNVector3(-baseS2 / 2.0, 0,      baseS2 / 2.0 * Float(tan(Double.pi / 180.0 * 30.0))),
            SCNVector3(baseS2 / 2.0,  0,      baseS2 / 2.0 * Float(tan(Double.pi / 180.0 * 30.0))),

            SCNVector3(0,             -baseS, 0),
            SCNVector3(0,             0,      -baseS2 / 2.0 / Float(cos(Double.pi / 180.0 * 30.0))),
            SCNVector3(-baseS2 / 2.0, 0,      baseS2 / 2.0 * Float(tan(Double.pi / 180.0 * 30.0))),

            SCNVector3(0,             -baseS, 0),
            SCNVector3(0,             0,      -baseS2 / 2.0 / Float(cos(Double.pi / 180.0 * 30.0))),
            SCNVector3(baseS2 / 2.0,  0,      baseS2 / 2.0 * Float(tan(Double.pi / 180.0 * 30.0))),
            ]
        let normals: [SCNVector3] = [
            SCNVector3(0,  0, 1),
            SCNVector3(0,  0, 1),
            SCNVector3(0,  0, 1),

            SCNVector3(-1, 0, 0),
            SCNVector3(-1, 0, 0),
            SCNVector3(-1, 0, 0),

            SCNVector3(1,  0, 0),
            SCNVector3(1,  0, 0),
            SCNVector3(1,  0, 0),

            SCNVector3(0,  0, 1),
            SCNVector3(0,  0, 1),
            SCNVector3(0,  0, 1),

            SCNVector3(-1, 0, 0),
            SCNVector3(-1, 0, 0),
            SCNVector3(-1, 0, 0),

            SCNVector3(1,  0, 0),
            SCNVector3(1,  0, 0),
            SCNVector3(1,  0, 0),
            ]
        let indices: [Int32] = [
            0, 1,  2,
            3, 4,  5,
            6, 8,  7,
            11, 10,  9,
            14, 13,  12,
            16, 17,  15,
            ]
        let texcoords: [float2] = [
            float2(1, 1),
            float2(1, 1),
            float2(0, 0),

            float2(1, 1),
            float2(1, 1),
            float2(0, 0),

            float2(1, 1),
            float2(1, 1),
            float2(0, 0),

            float2(1, 1),
            float2(1, 1),
            float2(0, 0),

            float2(1, 1),
            float2(1, 1),
            float2(0, 0),

            float2(1, 1),
            float2(1, 1),
            float2(0, 0),
            ]
        let verticesSource: SCNGeometrySource = SCNGeometrySource(vertices: vertices)
        let normalsSource: SCNGeometrySource = SCNGeometrySource(normals: normals)
        //let verticesSource = SCNGeometrySource(vertices: vertices, count: vertices.count)
        //let normalsSource = SCNGeometrySource(normals: normals, count: normals.count)
        let texcoordSource: SCNGeometrySource = SCNGeometrySource(textureCoordinates: texcoords)
        let faceSource: SCNGeometryElement = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        return SCNGeometry(sources: [verticesSource, normalsSource, texcoordSource], elements: [faceSource])
    }

    func makeTemperatureCrystalGeometry(_ size: Float) -> SCNGeometry {

        let baseS: Float = size * 0.5
        let baseS2: Float = size * 0.4
        let topH: Float = size * 0.6
        //let bottomH: Float = size * 0.3
        let vertices: [SCNVector3] = [
            SCNVector3(0,             baseS,  0),
            SCNVector3(-baseS2 / 2.0, baseS - topH,      baseS2 / 2.0),
            SCNVector3(baseS2 / 2.0,  baseS - topH,      baseS2 / 2.0),

            SCNVector3(0,             baseS,  0),
            SCNVector3(-baseS2 / 2.0, baseS - topH,      -baseS2 / 2.0),
            SCNVector3(-baseS2 / 2.0,  baseS - topH,      baseS2 / 2.0),

            SCNVector3(0,             baseS,  0),
            SCNVector3(baseS2 / 2.0, baseS - topH,      -baseS2 / 2.0),
            SCNVector3(baseS2 / 2.0,  baseS - topH,      baseS2 / 2.0),

            SCNVector3(0,             baseS,  0),
            SCNVector3(-baseS2 / 2.0, baseS - topH,      -baseS2 / 2.0),
            SCNVector3(baseS2 / 2.0,  baseS - topH,      -baseS2 / 2.0),

            SCNVector3(0,             -baseS,  0),
            SCNVector3(-baseS2 / 2.0, baseS - topH,      baseS2 / 2.0),
            SCNVector3(baseS2 / 2.0,  baseS - topH,      baseS2 / 2.0),
            
            SCNVector3(0,             -baseS,  0),
            SCNVector3(-baseS2 / 2.0, baseS - topH,      -baseS2 / 2.0),
            SCNVector3(-baseS2 / 2.0,  baseS - topH,      baseS2 / 2.0),
            
            SCNVector3(0,             -baseS,  0),
            SCNVector3(baseS2 / 2.0, baseS - topH,      -baseS2 / 2.0),
            SCNVector3(baseS2 / 2.0,  baseS - topH,      baseS2 / 2.0),
            
            SCNVector3(0,             -baseS,  0),
            SCNVector3(-baseS2 / 2.0, baseS - topH,      -baseS2 / 2.0),
            SCNVector3(baseS2 / 2.0,  baseS - topH,      -baseS2 / 2.0),
            ]
        let normals: [SCNVector3] = [
            SCNVector3(0,  0, 1),
            SCNVector3(0,  0, 1),
            SCNVector3(0,  0, 1),
            
            SCNVector3(-1, 0, 0),
            SCNVector3(-1, 0, 0),
            SCNVector3(-1, 0, 0),
            
            SCNVector3(1,  0, 0),
            SCNVector3(1,  0, 0),
            SCNVector3(1,  0, 0),
            
            SCNVector3(0,  0, -1),
            SCNVector3(0,  0, -1),
            SCNVector3(0,  0, -1),

            SCNVector3(0,  0, 1),
            SCNVector3(0,  0, 1),
            SCNVector3(0,  0, 1),
            
            SCNVector3(-1, 0, 0),
            SCNVector3(-1, 0, 0),
            SCNVector3(-1, 0, 0),
            
            SCNVector3(1,  0, 0),
            SCNVector3(1,  0, 0),
            SCNVector3(1,  0, 0),
            
            SCNVector3(0,  0, -1),
            SCNVector3(0,  0, -1),
            SCNVector3(0,  0, -1),
            ]
        let indices: [Int32] = [
            0, 1,  2,
            3, 4,  5,
            6, 8,  7,
            11, 10,  9,
            14, 13,  12,
            17, 16,  15,
            19, 20,  18,
            21, 22,  23,
            ]
        let texcoords: [float2] = [
            float2(1, 1),
            float2(1, 1),
            float2(0, 0),
            
            float2(1, 1),
            float2(1, 1),
            float2(0, 0),
            
            float2(1, 1),
            float2(1, 1),
            float2(0, 0),
            
            float2(1, 1),
            float2(1, 1),
            float2(0, 0),
            
            float2(1, 1),
            float2(1, 1),
            float2(0, 0),
            
            float2(1, 1),
            float2(1, 1),
            float2(0, 0),
            
            float2(1, 1),
            float2(1, 1),
            float2(0, 0),
            
            float2(1, 1),
            float2(1, 1),
            float2(0, 0),
            ]
        let verticesSource: SCNGeometrySource = SCNGeometrySource(vertices: vertices)
        let normalsSource: SCNGeometrySource = SCNGeometrySource(normals: normals)
        //let verticesSource = SCNGeometrySource(vertices: vertices, count: vertices.count)
        //let normalsSource = SCNGeometrySource(normals: normals, count: normals.count)
        let texcoordSource: SCNGeometrySource = SCNGeometrySource(textureCoordinates: texcoords)
        let faceSource: SCNGeometryElement = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        return SCNGeometry(sources: [verticesSource, normalsSource, texcoordSource], elements: [faceSource])
    }

    func makeMagneticCrystalGeometry(w: Float, h: Float) -> SCNGeometry {

        let vertices: [SCNVector3] = [
            SCNVector3(0,            h / 2.0,  0),
            SCNVector3(w / 2.0,  -h / 2.0, 0),
            SCNVector3(-w / 2.0, -h / 2.0, 0),
            ]
        let normals: [SCNVector3] = [
            SCNVector3(0, 0, 1),
            SCNVector3(0, 0, 1),
            SCNVector3(0, 0, 1),
            ]
        let indices: [Int32] = [
            2, 1, 0,
            ]
        let texcoords: [float2] = [
            float2(0, 0),
            float2(1, 1),
            float2(0, 0),
            ]
        let verticesSource: SCNGeometrySource = SCNGeometrySource(vertices: vertices)
        let normalsSource: SCNGeometrySource = SCNGeometrySource(normals: normals)
        //let verticesSource = SCNGeometrySource(vertices: vertices, count: vertices.count)
        //let normalsSource = SCNGeometrySource(normals: normals, count: normals.count)
        let texcoordSource: SCNGeometrySource = SCNGeometrySource(textureCoordinates: texcoords)
        let faceSource: SCNGeometryElement = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        return SCNGeometry(sources: [verticesSource, normalsSource, texcoordSource], elements: [faceSource])
    }

    func setCrystalGeometryColor(_ value: Double) -> [SCNMaterial] {

        var colors: [CGColor] = []
        var count: Int = Int(value * 10)
        if count > 10 {
            count = 10
        }
        else if count < 0 {
            count = 0
        }
        //print("count: \(count)")

        let colorS: UIColor = UIColor(red: self.colorSR / 255.0,
                                      green: self.colorSG / 255.0,
                                      blue: self.colorSB / 255.0,
                                      alpha: 1)
        let colorE: UIColor = UIColor(red: self.colorER / 255.0,
                                      green: self.colorEG / 255.0,
                                      blue: self.colorEB / 255.0,
                                      alpha: 1)
        let colorR: CGFloat = (self.colorER - self.colorSR) / 5.0
        let colorG: CGFloat = (self.colorEG - self.colorSG) / 5.0
        let colorB: CGFloat = (self.colorEB - self.colorSB) / 5.0
        //print("colorE: \(colorE)")
        if count <= 5 {
            let color: UIColor = UIColor(red: (self.colorSR + colorR * CGFloat(count)) / 255.0,
                                         green: (self.colorSG + colorG * CGFloat(count)) / 255.0,
                                         blue: (self.colorSB + colorB * CGFloat(count)) / 255.0,
                                         alpha: 1)
            colors = [colorS.cgColor, color.cgColor]
        }
        else {
            let color: UIColor = UIColor(red: (self.colorSR + colorR * CGFloat(count - 5)) / 255.0,
                                         green: (self.colorSG + colorG * CGFloat(count - 5)) / 255.0,
                                         blue: (self.colorSB + colorB * CGFloat(count - 5)) / 255.0,
                                         alpha: 1)
            colors = [color.cgColor, colorE.cgColor]
        }
        //print("colors: \(colors)")

        let bgView: UIView = UIView()
        bgView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        let bgLayer: CAGradientLayer = CAGradientLayer()
        bgLayer.colors = colors
        bgLayer.startPoint = CGPoint(x: 0, y: 0.5)
        bgLayer.endPoint = CGPoint(x: 1, y: 0.5)
        bgLayer.frame = bgView.frame
        bgView.layer.addSublayer(bgLayer)
        let material: SCNMaterial = SCNMaterial()
        material.diffuse.contents = self.getImageFromView(bgView)
        material.isDoubleSided = true
        return [material, material, material, material]
    }

    func setCrystalGeometryColorOff(_ isGray: Bool) -> [SCNMaterial] {

        var color: UIColor = UIColor.darkPurple
        if isGray {
            color = UIColor.gray
        }

        let bgView: UIView = UIView()
        bgView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        bgView.backgroundColor = color
        let material: SCNMaterial = SCNMaterial()
        material.diffuse.contents = self.getImageFromView(bgView)
        material.isDoubleSided = true
        return [material]
    }
}

extension SCNGeometrySource {

    convenience init(textureCoordinates texcoord: [float2]) {

        let data = Data(bytes: texcoord, count: MemoryLayout<float2>.size * texcoord.count)
        self.init(data: data,
                  semantic: SCNGeometrySource.Semantic.texcoord,
                  vectorCount: texcoord.count,
                  usesFloatComponents: true,
                  componentsPerVector: 2,
                  bytesPerComponent: MemoryLayout<Float>.size,
                  dataOffset: 0,
                  dataStride: MemoryLayout<float2>.size)
    }
}
