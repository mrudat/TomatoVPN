/* $Id: sn_private.h,v 1.1.1.4 2003/10/14 08:09:11 sparq Exp $
 *
 * This file is subject to the terms and conditions of the GNU General Public
 * License.  See the file "COPYING" in the main directory of this archive
 * for more details.
 *
 * Copyright (C) 1992 - 1997, 2000-2001 Silicon Graphics, Inc. All rights reserved.
 */
#ifndef _ASM_IA64_SN_SN_PRIVATE_H
#define _ASM_IA64_SN_SN_PRIVATE_H

#include <linux/config.h>
#include <asm/sn/nodepda.h>
#include <asm/sn/xtalk/xwidget.h>
#include <asm/sn/xtalk/xtalk_private.h>

#if defined(CONFIG_IA64_SGI_SN1)
#include <asm/sn/sn1/sn_private.h>
#elif defined(CONFIG_IA64_SGI_SN2)
#include <asm/sn/sn2/sn_private.h>
#endif

#endif /* _ASM_IA64_SN_SN_PRIVATE_H */
