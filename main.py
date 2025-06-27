from fastapi import FastAPI, HTTPException, status
from pydantic import BaseModel
import uvicorn
import logging
from datetime import datetime, timezone
import os

# Configure logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="Item Service",
    description="A robust FastAPI service for managing items with health checks and basic CRUD.",
    version="1.0.0",
)

# A better DB representation
items_db = {
    "item1": {"name": "item1", "description": "First item"},
    "item2": {"name": "item2", "description": "Second item"},
}


class Item(BaseModel):
    name: str
    description: str | None = None


ITEM_NOT_FOUND_MSG = "Item not found"


@app.get("/health", status_code=status.HTTP_200_OK)
async def health_check():
    """
    Performs a health check on the service.
    Returns current status and timestamp.
    """
    logger.info("Health check requested.")
    return {
        "status": "healthy",
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }


@app.get("/items", status_code=status.HTTP_200_OK)
async def get_all_items():
    """
    Retrieves all available items.
    """
    logger.info("Retrieving all items.")
    return {"items": list(items_db.values())}


@app.get("/items/{item_name}", status_code=status.HTTP_200_OK)
async def get_item(item_name: str):
    """
    Retrieves a single item by its name.
    """
    if item_name not in items_db:
        logger.warning(f"Attempted to retrieve non-existent item: {item_name}")
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail=ITEM_NOT_FOUND_MSG
        )
    logger.info(f"Retrieving item: {item_name}")
    return {"item": items_db[item_name]}


@app.post("/items", status_code=status.HTTP_201_CREATED)
async def create_item(item: Item):
    """
    Creates a new item.
    """
    if item.name in items_db:
        logger.warning(f"Attempted to create duplicate item: {item.name}")
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Item with this name already exists",
        )
    items_db[item.name] = item.model_dump()
    logger.info(f"Item created: {item.name}")
    return {"message": "Item created successfully", "item": item}


@app.put("/items/{item_name}", status_code=status.HTTP_200_OK)
async def update_item(item_name: str, updated_item: Item):
    """
    Updates an existing item.
    """
    if item_name not in items_db:
        logger.warning(f"Attempted to update non-existent item: {item_name}")
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail=ITEM_NOT_FOUND_MSG
        )
    items_db[item_name].update(updated_item.model_dump())
    logger.info(f"Item updated: {item_name}")
    return {"message": "Item updated successfully", "item": items_db[item_name]}


@app.delete("/items/{item_name}", status_code=status.HTTP_200_OK)
async def delete_item(item_name: str):
    """
    Deletes an item by its name.
    """
    if item_name not in items_db:
        logger.warning(f"Attempted to delete non-existent item: {item_name}")
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail=ITEM_NOT_FOUND_MSG
        )

    deleted_item = items_db[item_name]  # Save before deletion
    del items_db[item_name]
    logger.info(f"Item deleted: {item_name}")
    return {"message": "Item deleted successfully", "item": deleted_item}


if __name__ == "__main__":  # pragma: no cover
    # Get port from environment variable, default to 8000
    port = int(os.environ.get("PORT", 8000))  # pragma: no cover
    uvicorn.run(app, host="0.0.0.0", port=port)  # pragma: no cover
