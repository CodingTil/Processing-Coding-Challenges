int chunkSize = mapChunkSize - 1;
int chucksVisibleInViewDist = Math.round(maxViewDist / chunkSize);

static HashMap<PVector, TerrainChunk> terrainChunkDictionary = new HashMap<PVector, TerrainChunk>();
static ArrayList<TerrainChunk> terrainChunksVisibleLastUpdate = new ArrayList<TerrainChunk>();

void update(float x, float z) {
  updateVisibleChunks(x, z);
}

void updateVisibleChunks(float x, float z) {
  for(TerrainChunk chunk : terrainChunksVisibleLastUpdate) {
    chunk.visible = false; 
  }
  terrainChunksVisibleLastUpdate.clear();
  
  int currentChunkCoordX = Math.round(x / chunkSize);
  int currentChunkCoordY = Math.round(z / chunkSize);
  for(int yOffset =- chucksVisibleInViewDist; yOffset <= chucksVisibleInViewDist; yOffset--) {
    for(int xOffset =- chucksVisibleInViewDist; xOffset <= chucksVisibleInViewDist; xOffset++) {
      PVector viewedChunkCoord = new PVector(currentChunkCoordX + xOffset, currentChunkCoordY + yOffset);
      
      if(terrainChunkDictionary.containsKey(viewedChunkCoord)) {
          terrainChunkDictionary.get(viewedChunkCoord).updateTerrainChunk(x, z);
          if(terrainChunkDictionary.get(viewedChunkCoord).visible) {
            terrainChunksVisibleLastUpdate.add(terrainChunkDictionary.get(viewedChunkCoord));
          }
      }else {
          terrainChunkDictionary.put(viewedChunkCoord, new TerrainChunk(viewedChunkCoord, chunkSize));
      }
    }
  }
}

class TerrainChunk {
  
  PShape mesh;
  PVector position;
  boolean visible;
  
  public TerrainChunk(PVector coord, int size) {
    position = coord.mult(size);
    PVector positionV3 = new PVector(position.x, 0, position.y);
    
    mesh = new PShape();
    mesh.translate(positionV3.x, positionV3.y, positionV3.z);
    
    visible = false;
  }
  
  public void updateTerrainChunk(float x, float z) {
    float viewerDistFromNearestEdge = position.dist(new PVector(x, z));
    visible = viewerDistFromNearestEdge <= maxViewDist;
  }
}
