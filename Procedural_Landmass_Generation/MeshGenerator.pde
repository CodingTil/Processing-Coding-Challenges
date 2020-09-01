PShape generateTerrainMesh(float[][] heightMap, int levelOfDetail) {
  int meshSimplificationIncrement = (levelOfDetail == 0) ? 1 : levelOfDetail * 2;

  PShape map = createShape();
  map.beginShape(TRIANGLE);
  map.noStroke();
  for (int y = 0; y < heightMap.length - 1; y += meshSimplificationIncrement) {
    for (int x = 0; x < heightMap.length - 1; x += meshSimplificationIncrement) {
      map.fill(mostColor(TerrainType.getColorForFloat(noiseMap[x][y]), TerrainType.getColorForFloat(noiseMap[x][y + meshSimplificationIncrement]), TerrainType.getColorForFloat(noiseMap[x + meshSimplificationIncrement][y])));
      map.vertex(x, y, map(noiseMap[x][y], 0, 1, 0, scaleCurve(noiseMap[x][y])));
      map.vertex(x, y + meshSimplificationIncrement, map(noiseMap[x][y + meshSimplificationIncrement], 0, 1, 0, scaleCurve(noiseMap[x][y + meshSimplificationIncrement])));
      map.vertex(x + meshSimplificationIncrement, y, map(noiseMap[x + meshSimplificationIncrement][y], 0, 1, 0, scaleCurve(noiseMap[x + meshSimplificationIncrement][y])));

      map.fill(mostColor(TerrainType.getColorForFloat(noiseMap[x + meshSimplificationIncrement][y]), TerrainType.getColorForFloat(noiseMap[x][y + meshSimplificationIncrement]), TerrainType.getColorForFloat(noiseMap[x + meshSimplificationIncrement][y + meshSimplificationIncrement])));
      map.vertex(x + meshSimplificationIncrement, y, map(noiseMap[x + meshSimplificationIncrement][y], 0, 1, 0, scaleCurve(noiseMap[x + meshSimplificationIncrement][y])));
      map.vertex(x, y + meshSimplificationIncrement, map(noiseMap[x][y + meshSimplificationIncrement], 0, 1, 0, scaleCurve(noiseMap[x][y + meshSimplificationIncrement])));
      map.vertex(x + meshSimplificationIncrement, y + meshSimplificationIncrement, map(noiseMap[x + meshSimplificationIncrement][y + meshSimplificationIncrement], 0, 1, 0, scaleCurve(noiseMap[x + meshSimplificationIncrement][y + meshSimplificationIncrement])));
    }
  }
  map.endShape();
  return map;
}

private float scaleCurve(float value) {
  return value * value * 10;
}

private color mostColor(color c1, color c2, color c3) {
  if (sameColors(c1, c2)) {
    return c1;
  }
  if (sameColors(c1, c3)) {
    return c1;
  }
  if (sameColors(c2, c3)) {
    return c2;
  }
  return c3;
}

private boolean sameColors(color c1, color c2) {
  if (red(c1) == red(c2) && green(c1) == green(c2) && blue(c1) == blue(c2)) return true;
  return false;
}
