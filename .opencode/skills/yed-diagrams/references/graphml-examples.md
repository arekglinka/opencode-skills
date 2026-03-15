# yEd GraphML Reference

## Full Node Examples

### Standard Class Node

```xml
<node id="n0">
  <data key="d6">
    <y:ShapeNode>
      <y:Geometry width="140" height="60" x="0" y="0"/>
      <y:Fill color="#87CEEB" transparent="false"/>
      <y:BorderStyle color="#000000" type="line" width="1.0"/>
      <y:NodeLabel>&lt;b&gt;ClassName&lt;/b&gt;&lt;br/&gt;attribute: type</y:NodeLabel>
      <y:Shape type="roundrectangle"/>
    </y:ShapeNode>
  </data>
</node>
```

### Decision Diamond

```xml
<node id="n1">
  <data key="d6">
    <y:ShapeNode>
      <y:Geometry width="100" height="60" x="200" y="0"/>
      <y:Fill color="#FFA07A" transparent="false"/>
      <y:BorderStyle color="#000000" type="line" width="2.0"/>
      <y:NodeLabel>Condition?</y:NodeLabel>
      <y:Shape type="diamond"/>
    </y:ShapeNode>
  </data>
</node>
```

### Storage Cylinder

```xml
<node id="n2">
  <data key="d6">
    <y:ShapeNode>
      <y:Geometry width="100" height="60" x="400" y="0"/>
      <y:Fill color="#E8E8E8" transparent="false"/>
      <y:BorderStyle color="#000000" type="line" width="1.0"/>
      <y:NodeLabel>Database</y:NodeLabel>
      <y:Shape type="cylinder"/>
    </y:ShapeNode>
  </data>
</node>
```

### Start/End Ellipse

```xml
<node id="n3">
  <data key="d6">
    <y:ShapeNode>
      <y:Geometry width="80" height="40" x="0" y="100"/>
      <y:Fill color="#98FB98" transparent="false"/>
      <y:BorderStyle color="#000000" type="line" width="2.0"/>
      <y:NodeLabel>Start</y:NodeLabel>
      <y:Shape type="ellipse"/>
    </y:ShapeNode>
  </data>
</node>
```

## Edge Variations

### Labeled Edge

```xml
<edge id="e0" source="n0" target="n1">
  <data key="d9">
    <y:PolyLineEdge>
      <y:Arrows source="none" target="standard"/>
      <y:EdgeLabel>uses</y:EdgeLabel>
    </y:PolyLineEdge>
  </data>
</edge>
```

### Dashed Edge (Inheritance)

```xml
<edge id="e1" source="n0" target="n1">
  <data key="d9">
    <y:PolyLineEdge>
      <y:Arrows source="none" target="delta"/>
      <y:LineStyle type="dashed" color="#000000" width="1.0"/>
    </y:PolyLineEdge>
  </data>
</edge>
```

### Composition Edge

```xml
<edge id="e2" source="n0" target="n1">
  <data key="d9">
    <y:PolyLineEdge>
      <y:Arrows source="diamond" target="none"/>
    </y:PolyLineEdge>
  </data>
</edge>
```

## Common Pitfalls

| Issue | Cause | Fix |
|-------|-------|-----|
| Yellow square only | Missing y:ShapeNode | Wrap content in y:ShapeNode |
| Not visible | Missing yfiles.type | Add `yfiles.type="nodegraphics"` |
| Wrong shape | Incorrect type | Use `roundrectangle`, `diamond`, etc. |
| Label not showing | Missing NodeLabel | Add y:NodeLabel element |
| Layout messy | No x,y coords | Add Geometry with x,y |

## Minimal Working File

```xml
<?xml version="1.0" encoding="UTF-8"?>
<graphml xmlns="http://graphml.graphdrawing.org/xmlns"
         xmlns:y="http://www.yworks.com/xml/graphml">
  <key for="node" id="d6" yfiles.type="nodegraphics"/>
  <key for="edge" id="d9" yfiles.type="edgegraphics"/>
  <graph id="G" edgedefault="directed">
    <node id="n0">
      <data key="d6">
        <y:ShapeNode>
          <y:Geometry width="100" height="40"/>
          <y:Fill color="#87CEEB"/>
          <y:NodeLabel>Hello</y:NodeLabel>
          <y:Shape type="roundrectangle"/>
        </y:ShapeNode>
      </data>
    </node>
  </graph>
</graphml>
```
