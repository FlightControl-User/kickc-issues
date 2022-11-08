#pragma var_model(zp)

#include <cx16.h>
#include <conio.h>
#include <printf.h>
#include <cx16-veralib.h>
#include <lru-cache.h>
#include <cx16-veraheap.h>
#include <cx16-heap-bram-fb.h>

typedef struct {
    unsigned char used[16];
    void* sprite_bram[16]; // TODO: I need to get rid of this ...
    unsigned char count[16];
    unsigned int offset[16];
    unsigned int size[16];
    unsigned char zdepth[16];
    unsigned char bpp[16];
    unsigned char width[16];
    unsigned char height[16];
    unsigned char hflip[16];
    unsigned char vflip[16];
    unsigned char reverse[16];
    unsigned char speed[16];
    unsigned char loop[16];
    unsigned char palette_offset[16];
    unsigned char file[16*16];
    unsigned char aabb[16*4];
} fe_sprite_cache_t;

typedef unsigned char fe_sprite_index_t;
typedef heap_bram_fb_handle_t sprite_bram_handles_t;

lru_cache_table_t sprite_cache_vram;
fe_sprite_cache_t sprite_cache;
__export volatile sprite_bram_handles_t sprite_bram_handles[512];



vera_sprite_image_offset sprite_image_cache_vram(fe_sprite_index_t fe_sprite_index, unsigned char fe_sprite_image_index)
{
    // check if the image in vram is in use where the fe_sprite_vram_image_index is pointing to.
    // if this vram_image_used is false, that means that the image in vram is not in use anymore (not displayed or destroyed).

    unsigned int image_index = sprite_cache.offset[fe_sprite_index] + fe_sprite_image_index;

    // We retrieve the image from BRAM from the sprite_control bank.
    // TODO: what if there are more sprite control data than that can fit into one CX16 bank?
    bank_push_set_bram(1);
    heap_bram_fb_handle_t handle_bram = sprite_bram_handles[image_index];
    bank_pull_bram();

    // We declare temporary variables for the vram memory handles.
    // lru_cache_data_t vram_handle;
    // vram_bank_t vram_bank;
    // vram_offset_t vram_offset;

    // We check if there is a cache hit?
    __export lru_cache_index_t vram_index2 = lru_cache_index_get(&sprite_cache_vram, 2);
    lru_cache_index_t vram_index = lru_cache_index_get(&sprite_cache_vram, 1);
    // lru_cache_data_t lru_cache_data;
    vera_sprite_image_offset sprite_offset = 0;
    if (vram_index != 0xFF) {

//         // So we have a cache hit, so we can re-use the same image from the cache and we win time!
//         lru_cache_data_t vram_handle = lru_cache_get(&sprite_cache_vram, vram_index);

//         // Now that we are sure that there is sufficient space in vram and on the cache, we allocate a new element.
//         // Dynamic allocation of sprites in vera vram.
//         vram_bank_t vram_bank = vera_heap_data_get_bank(1, vram_handle);
//         vram_offset_t vram_offset = vera_heap_data_get_offset(1, vram_handle);

//         sprite_offset = vera_sprite_get_image_offset(vram_bank, vram_offset);
//     } else {

// #ifdef __CPULINES
//         vera_display_set_border_color(RED);
// #endif

//         // The idea of this section is to free up lru_cache and/or vram memory until there is sufficient space available.
//         // The size requested contains the required size to be allocated on vram.
//         vera_heap_size_int_t vram_size_required = sprite_cache.size[fe_sprite_index];

//         // We check if the vram heap has sufficient memory available for the size requested.
//         // We also check if the lru cache has sufficient elements left to contain the new sprite image.
//         bool vram_has_free = vera_heap_has_free(1, vram_size_required);
//         bool lru_cache_max = lru_cache_is_max(&sprite_cache_vram);

//         // Free up the lru_cache and vram memory until the requested size is available!
//         // This ensures that vram has sufficient place to allocate the new sprite image. 
//         while (lru_cache_max || !vram_has_free) {

//             // If the cache is at it's maximum, before we can add a new element, we must remove the least used image.
//             // We search for the least used image in vram.
//             lru_cache_key_t vram_last = lru_cache_find_last(&sprite_cache_vram);

//             // We delete the least used image from the vram cache, and this function returns the stored vram handle obtained by the vram heap manager.
//             lru_cache_data_t vram_handle = lru_cache_delete(&sprite_cache_vram, vram_last);
//             if (vram_handle == 0xFFFF) {
// #ifdef __INCLUDE_PRINT
//                 gotoxy(0, 59);
//                 printf("error! vram_handle is nothing!");
// #endif
//             }

//             // And we free the vram heap with the vram handle that we received.
//             // But before we can free the heap, we must first convert back from teh sprite offset to the vram address.
//             // And then to a valid vram handle :-).
//             vera_heap_free(1, vram_handle);
//             vram_has_free = vera_heap_has_free(1, vram_size_required);
//             lru_cache_max = lru_cache_is_max(&sprite_cache_vram);
//         }

//         // Now that we are sure that there is sufficient space in vram and on the cache, we allocate a new element.
//         // Dynamic allocation of sprites in vera vram.
//         lru_cache_data_t vram_handle = vera_heap_alloc(1, (unsigned long)sprite_cache.size[fe_sprite_index]);
//         vram_bank_t vram_bank = vera_heap_data_get_bank(1, vram_handle);
//         vram_offset_t vram_offset = vera_heap_data_get_offset(1, vram_handle);

//         memcpy_vram_bram(vram_bank, vram_offset, heap_bram_fb_bank_get(handle_bram), (bram_ptr_t)heap_bram_fb_ptr_get(handle_bram), sprite_cache.size[fe_sprite_index]);

//         sprite_offset = vera_sprite_get_image_offset(vram_bank, vram_offset);
//         lru_cache_insert(&sprite_cache_vram, image_index, vram_handle);

// #ifdef __CPULINES
//         vera_display_set_border_color(BLACK);
// #endif
    }

    // We return the image offset in vram of the sprite to be drawn.
    // This offset is used by the vera image set offset function to directly change the image displayed of the sprite!
    return sprite_offset;
}

void main() {
    clrscr();
    gotoxy(0,1);

    __export vera_sprite_image_offset v1 = sprite_image_cache_vram(1, 2);
    __export vera_sprite_image_offset v2 = sprite_image_cache_vram(2, 4);

}
