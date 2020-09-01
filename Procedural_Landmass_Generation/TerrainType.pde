public enum TerrainType {

    WATER_DEEP(0.3, #282181, "Water - deep"), 
    WATER_SHALLOW(0.4, #2362B7, "Water - shallow"), 
    SAND(0.45, #B7B023, "Sand"), 
    GRASS_LIGHT(0.55, #485D22, "Grass - light"), 
    GRASS_DARK(0.6, #394D14, "Grass - dark"), 
    ROCK_LIGHT(0.7, #55421B, "Rock - light"), 
    ROCK_DARK(0.9, #272011, "Rock - dark"), 
    SNOW(1, #E8FBFC, "Snow");

  private float h;
  private color hex;
  private String name;

  private TerrainType(float h, color hex, String name) {
    this.h = h;
    this.hex = hex;
    this.name = name;
  }

  public float getHeight() {
    return h;
  }

  public color getHex() {
    return hex;
  }

  public String getName() {
    return name;
  }

  static TerrainType[] regions = new TerrainType[]{TerrainType.WATER_DEEP, TerrainType.WATER_SHALLOW, TerrainType.SAND, TerrainType.GRASS_LIGHT, TerrainType.GRASS_DARK, TerrainType.ROCK_LIGHT, TerrainType.ROCK_DARK, TerrainType.SNOW};

  public static color getColorForFloat(float value) {
    for (int i = 0; i < regions.length; i++) {
      if (value <= regions[i].getHeight()) { 
        return regions[i].getHex();
      }
    }
    return #ffffff;
  }
}
