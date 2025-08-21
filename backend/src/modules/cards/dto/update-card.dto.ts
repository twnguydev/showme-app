// src/modules/cards/dto/update-card.dto.ts
import { PartialType, OmitType } from '@nestjs/mapped-types';
import { CreateCardDto } from './create-card.dto';

export class UpdateCardDto extends PartialType(
  OmitType(CreateCardDto, ['slug'] as const)
) {
  // Le slug ne peut pas être modifié après création
}