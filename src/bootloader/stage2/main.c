#include "disk.h"
#include "fat.h"
#include "stdint.h"
#include "stdio.h"
#include "x86.h"

void far* g_data = (void far*)0x00500200;

#define MAX_HANDLES 16
#define TARGET_SIZE 10*1024 // 80 KB

void _cdecl cstart_(uint16_t bootDrive)
{
    printf("Hello from C!\r\n\n");

    DISK disk;
    if (!DISK_Initialize(&disk, bootDrive)) {
        printf("Disk init error\r\n");
        goto end;
    }

    DISK_ReadSectors(&disk, 19, 1, g_data);

    if (!FAT_Initialize(&disk)) {
        printf("FAT init error\r\n");
        goto end;
    }

    printf("Directory of '::/':\r\n");

    FAT_File far* fd = FAT_Open(&disk, "/");
    FAT_DirectoryEntry entry;
    int i = 0;

    while (FAT_ReadEntry(&disk, fd, &entry) && i++ < 5)
    {
        printf("  ");
        for (int i = 0; i < 11; i++)
            putc(entry.Name[i]);
        printf("\r\n");
    }

    FAT_Close(fd);

    printf("Contents of '::/testdir/test.txt':\r\n");

    char buffer[100];
    uint32_t read;
    fd = FAT_Open(&disk, "testdir/test.txt");

    while ((read = FAT_Read(&disk, fd, sizeof(buffer), buffer))) {
        for (uint32_t i = 0; i < read; i++)
        {
            if (buffer[i] == '\n')
                putc('\r');
            putc(buffer[i]);
        }
    }

    FAT_Close(fd);

    printf("\r\n");

    FAT_File far* handles[MAX_HANDLES] = {0};
    int opened = 0;

    for (int i = 0; i < MAX_HANDLES; i++) {
        handles[i] = FAT_Open(&disk, "stage2.bin");  // or any valid file
        if (handles[i]) {
            opened++;
        } else {
            break;
        }
    }

    printf("Opened %d handles\r\n", opened);

    for (int i = 0; i < opened; i++) {
        FAT_Close(handles[i]);
    }

end:
    x86_Halt();
}
