# yEd Diagrams

Generate valid yEd-compatible GraphML diagrams from code analysis.

## When to Use

- Visualize architecture, class hierarchies, data flows
- Create migration planning diagrams
- Document system relationships
- Any diagram that will be opened in yEd

## GraphML Structure

```xml
<?xml version="1.0" encoding="UTF-8"?>
<graphml xmlns="http://graphml.graphdrawing.org/xmlns"
         xmlns:y="http://www.yworks.com/xml/graphml">
  <key for="node" id="d6" yfiles.type="nodegraphics"/>
  <key for="edge" id="d9" yfiles.type="edgegraphics"/>
  
  <graph id="G" edgedefault="directed">
    <!-- nodes and edges here -->
  </graph>
</graphml>
```

## Nodes

| Shape | Type | Use Case |
|-------|------|----------|
| `roundrectangle` | Default | Components, classes |
| `rectangle` | Simple | Files, modules |
| `ellipse` | Start/end | Terminal states |
| `diamond` | Decision | Conditionals, choices |
| `cylinder` | Storage | Databases, files |

### Node Template

```xml
<node id="n0">
  <data key="d6">
    <y:ShapeNode>
      <y:Geometry width="120" height="40" x="0" y="0"/>
      <y:Fill color="#87CEEB" transparent="false"/>
      <y:BorderStyle color="#000000" type="line" width="1.0"/>
      <y:NodeLabel>Label Text</y:NodeLabel>
      <y:Shape type="roundrectangle"/>
    </y:ShapeNode>
  </data>
</node>
```

### HTML Labels

```xml
<y:NodeLabel>&lt;html&gt;&lt;b&gt;ClassName&lt;/b&gt;&lt;br/&gt;attribute&lt;/html&gt;</y:NodeLabel>
```

## Edges

### Basic Edge

```xml
<edge id="e0" source="n0" target="n1">
  <data key="d9">
    <y:PolyLineEdge>
      <y:Arrows source="none" target="standard"/>
    </y:PolyLineEdge>
  </data>
</edge>
```

### Arrow Types

| Target | Meaning |
|--------|---------|
| `standard` | Association |
| `delta` | Inheritance (△) |
| `diamond` | Composition (◆) |
| `none` | No arrow |

### Edge Labels

```xml
<y:PolyLineEdge>
  <y:Arrows source="none" target="standard"/>
  <y:EdgeLabel>uses</y:EdgeLabel>
</y:PolyLineEdge>
```

### Line Styles

```xml
<y:LineStyle type="dashed"/>  <!-- for inheritance/abstract -->
<y:LineStyle type="dotted"/>  <!-- for optional/weak -->
```

## Color Palette

| Color | Hex | Use |
|-------|-----|-----|
| Blue | `#87CEEB` | Primary/standard |
| Green | `#98FB98` | Success/complete |
| Pink | `#FFB6C1` | New/added |
| Purple | `#DDA0DD` | Strategy/logic |
| Orange | `#FFA07A` | Decision/warning |
| Yellow | `#F0E68C` | Foundation/base |
| Gray | `#E8E8E8` | External/storage |

## Common Patterns

### Inheritance

```xml
<edge source="parent" target="child">
  <data key="d9">
    <y:PolyLineEdge>
      <y:Arrows source="none" target="delta"/>
      <y:LineStyle type="dashed"/>
    </y:PolyLineEdge>
  </data>
</edge>
```

### Composition

```xml
<edge source="container" target="contained">
  <data key="d9">
    <y:PolyLineEdge>
      <y:Arrows source="none" target="diamond"/>
    </y:PolyLineEdge>
  </data>
</edge>
```

### Flow/Sequence

```xml
<edge source="step1" target="step2">
  <data key="d9">
    <y:PolyLineEdge>
      <y:Arrows source="none" target="standard"/>
    </y:PolyLineEdge>
  </data>
</edge>
```

## Workflow

```
1. Analyze code → identify nodes (classes, components, files)
2. Determine relationships → edges (inheritance, composition, flow)
3. Assign shapes by type (rect=class, diamond=decision, cylinder=data)
4. Apply colors by category (consistent palette)
5. Position nodes (x, y coordinates for readability)
6. Add edge labels for relationship types
```

## Tips

- Use unique IDs: `n0`, `n1`, ... for nodes, `e0`, `e1`, ... for edges
- Position nodes manually with x, y for readable layout
- Keep labels short; use HTML for formatting
- Group related nodes by color
- yEd can auto-layout after opening if needed
