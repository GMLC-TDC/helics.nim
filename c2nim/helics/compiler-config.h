/*
* LLNS Copyright Start
 * Copyright (c) 2017, Lawrence Livermore National Security
 * This work was performed under the auspices of the U.S. Department
 * of Energy by Lawrence Livermore National Laboratory in part under
 * Contract W-7405-Eng-48 and in part under Contract DE-AC52-07NA27344.
 * Produced at the Lawrence Livermore National Laboratory.
 * All rights reserved.
 * For details, see the LICENSE file.
 * LLNS Copyright End
 */
#ifndef COMPILER_CONFIG_H
#define COMPILER_CONFIG_H
#pragma once

/* #undef HAVE_STRING_VIEW */

/* #undef HAVE_EXP_STRING_VIEW */

/* #undef HAVE_FILESYSTEM */

/* #undef HAVE_OPTIONAL */

/* #undef HAVE_VARIANT */

#define HAVE_VARIABLE_TEMPLATES

/* #undef HAVE_IF_CONSTEXPR */

#ifdef HAVE_IF_CONSTEXPR
#define IF_CONSTEXPR  constexpr
#else
#define IF_CONSTEXPR /* disables code */
#endif

/* #undef HAVE_FALLTHROUGH */

#ifdef HAVE_FALLTHROUGH
#define FALLTHROUGH [[fallthrough]]; /* FALLTHRU */
#else
#define FALLTHROUGH /* FALLTHRU */
#endif

/* #undef HAVE_UNUSED */

#ifdef HAVE_UNUSED
#define UNUSED [[maybe_unused]]
#else
#define UNUSED /* UNUSED */
#endif

/* #undef HAVE_CLAMP */

/* #undef HAVE_HYPOT3 */

#define HAVE_SHARED_TIMED_MUTEX

/* #undef HAVE_SHARED_MUTEX */

#endif // COMPILER_CONFIG_H

