import type { FastifyReply, FastifyRequest } from "fastify";

import { userHasRole, type UserRole } from "../../data/authz-store.js";
import {
  getManagedSpecialistProfileId,
  getProfile,
  getUserIdForAccessToken,
} from "../../data/persistent-store.js";
import { readAccessToken } from "./auth.js";

export async function requireAuthenticatedUser(
  request: FastifyRequest,
  reply: FastifyReply,
): Promise<string | null> {
  const accessToken = readAccessToken(request.headers.authorization);
  if (!accessToken) {
    reply.code(401);
    return null;
  }

  const userId = await getUserIdForAccessToken(accessToken);
  if (!userId) {
    reply.code(401);
    return null;
  }

  return userId;
}

export async function requireRole(
  request: FastifyRequest,
  reply: FastifyReply,
  role: UserRole,
): Promise<string | null> {
  const userId = await requireAuthenticatedUser(request, reply);
  if (!userId) {
    return null;
  }

  if (!(await userHasRole(userId, role))) {
    reply.code(403);
    return null;
  }

  return userId;
}

export async function requireSpecialistProfile(
  request: FastifyRequest,
  reply: FastifyReply,
): Promise<string | null> {
  const userId = await requireAuthenticatedUser(request, reply);
  if (!userId) {
    return null;
  }

  const user = await getProfile(userId);
  if (user.accountType !== "specialist") {
    reply.code(403);
    return null;
  }

  return userId;
}

export async function requireManagedSpecialistProfile(
  request: FastifyRequest,
  reply: FastifyReply,
): Promise<{ userId: string; specialistProfileId: string } | null> {
  const userId = await requireSpecialistProfile(request, reply);
  if (!userId) {
    return null;
  }

  const specialistProfileId = await getManagedSpecialistProfileId(userId);
  if (!specialistProfileId) {
    reply.code(403);
    return null;
  }

  return { userId, specialistProfileId };
}
